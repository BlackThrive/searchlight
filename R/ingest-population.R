#' Construct an explicit exposure table
#'
#' Population is an exposure. Unknown ethnicity has no Census population
#' denominator and must have NA population. Additional age_band and sex columns
#' identify disjoint strata. Counts may exceed exposure.
#' @param data A data frame with geography_code, ethnicity and population.
#' @param geography Geography type and vintage, for example msoa21.
#' @param classification Self-defined classification, 5 or 19.
#' @param source Description of a user-supplied exposure.
#' @return A tibble with class sl_exposure and an exposure contract.
#' @family ingest
#' @seealso [sl_population()], [sl_population_crosstab()]
#' @export
#' @examples
#' sl_exposure(data.frame(
#'   geography_code = "area1", ethnicity = "White",
#'   population = 1000
#' ), geography = "example")
sl_exposure <- function(data, geography, classification = c("5", "19"),
                        source = "user_supplied") {
  classification <- match.arg(classification)
  sl_require_columns(data, c("geography_code", "ethnicity", "population"))
  data <- tibble::as_tibble(data)
  groups <- unique(sl_table("nomis-ethnicity.csv")[[
    paste0("ethnicity_", classification)
  ]])
  invalid <- anyNA(data$geography_code) || anyNA(data$ethnicity) ||
    any(!data$ethnicity %in% c(groups, "Unknown"))
  if (invalid) {
    sl_abort("Exposure has missing codes or incompatible ethnicity labels.")
  }
  known <- data$ethnicity != "Unknown"
  invalid <- !is.numeric(data$population) ||
    any(!is.finite(data$population[known]) | data$population[known] < 0) ||
    any(!is.na(data$population[!known]))
  if (invalid) {
    sl_abort("Known exposure must be finite and nonnegative; Unknown is NA.")
  }
  keys <- intersect(
    c("geography_code", "ethnicity", "age_band", "sex"),
    names(data)
  )
  if (anyDuplicated(data[keys])) sl_abort("Duplicate exposure strata.")
  contract <- sl_new_contract()
  contract$source <- source
  contract$population <- list(
    source = "user_supplied", description = source, geography = geography,
    classification = classification, retrieved = Sys.time(), vintage = NA
  )
  sl_carry(data, contract, "sl_exposure")
}

#' Census 2021 ethnicity populations
#'
#' Fetches TS021 (NM_2041_1), with exact codes verified against returned cells.
#' Supply ONS codes or an sf boundary object. Current ward and LAD boundaries
#' must not be silently matched to Census 2021 units: unchanged codes alone do
#' not demonstrate unchanged boundaries. A new exposure source must be supplied
#' for changed units. Census disclosure control may cause small inconsistencies
#' between separately published tables. Unknown is retained with NA exposure.
#' @param geography ONS geography codes, or an sf layer with geography_code.
#' @param classification Census classification, 5 or 19.
#' @param dir Explicit cache directory, written only on this call.
#' @return An sl_exposure tibble, or NULL with a message if unavailable.
#' @family ingest
#' @seealso [sl_exposure()], [sl_population_crosstab()]
#' @export
#' @examples
#' p <- readRDS(system.file("extdata", "sample-population.rds",
#'   package = "searchlight"
#' ))
#' head(p$msoa21)
sl_population <- function(geography, classification = c("5", "19"),
                          dir = sl_cache_dir()) {
  sl_nomis_population(geography, match.arg(classification), dir, FALSE)
}

#' Census ethnicity by age and sex
#'
#' Uses RM032 (NM_2132_1), available at Census 2021 small areas.
#' Five published age bands are combined to under 25, 25-34 and 35+, the common
#' partition with police age bands. Census sex and police-recorded gender are
#' different measurements; any analysis using them must state this assumption.
#' Unsupported geography returns NULL and a message. No age-sex cross-tabulation
#' is imputed from marginal totals.
#' @inheritParams sl_population
#' @return An sl_exposure tibble with age_band and sex, or NULL.
#' @family ingest
#' @seealso [sl_population()], [sl_exposure()]
#' @export
#' @examples
#' p <- readRDS(system.file("extdata", "sample-crosstab.rds",
#'   package = "searchlight"
#' ))
#' head(p)
sl_population_crosstab <- function(geography, dir = sl_cache_dir(),
                                   classification = c("5", "19")) {
  sl_nomis_population(geography, match.arg(classification), dir, TRUE)
}

#' @noRd
sl_population_codes <- function(geography) {
  if (is.data.frame(geography)) {
    sl_require_columns(geography, "geography_code")
    metadata <- attr(geography, "geography_metadata")
    invalid <- !is.null(metadata$type) && metadata$type %in% c("lad", "ward") &&
      !grepl("^2021", metadata$vintage)
    if (invalid) {
      sl_abort(
        "Supply Census 2021 codes or an explicit compatible exposure.",
        "population"
      )
    }
    geography <- geography$geography_code
  }
  invalid <- !is.character(geography) || !length(geography) ||
    anyNA(geography) ||
    any(!grepl("^[EWK][0-9]{8}$", geography))
  if (invalid) {
    sl_abort("Geography must contain ONS codes or a boundary layer.")
  }
  sort(unique(geography))
}

#' @noRd
sl_nomis_population <- function(geography, classification, dir, cross) {
  codes <- sl_population_codes(geography)
  prefix <- unique(substr(codes, 1, 3))
  types <- c(
    E01 = "lsoa21", W01 = "lsoa21", E02 = "msoa21", W02 = "msoa21",
    E06 = "lad21", E07 = "lad21", E08 = "lad21", E09 = "lad21", W06 = "lad21",
    E05 = "ward21", W05 = "ward21", E92 = "country", W92 = "country",
    K04 = "england_wales"
  )
  type <- unique(unname(types[prefix]))
  if (anyNA(type) || length(type) != 1L) {
    cli::cli_inform("Census table unavailable for this geography selection.")
    return(NULL)
  }
  table <- if (cross) "NM_2132_1" else "NM_2041_1"
  key <- digest::digest(list(codes, classification, table), algo = "sha256")
  path <- file.path(dir, paste0("population-", key, ".rds"))
  if (file.exists(path)) {
    return(readRDS(path))
  }
  pages <- list()
  for (chunk in split(codes, ceiling(seq_along(codes) / 20))) {
    query <- list(
      geography = paste(chunk, collapse = ","),
      c2021_eth_20 = "1...19", measures = 20100, recordlimit = 25000
    )
    if (cross) {
      query$c2021_age_6 <- "1...5"
      query$c_sex <- "1,2"
    }
    url <- sl_query_url(paste0(
      "https://www.nomisweb.co.uk/api/v01/dataset/",
      table, ".data.csv"
    ), query)
    response <- sl_get(url)
    if (is.null(response)) {
      return(NULL)
    }
    body <- httr2::resp_body_string(response)
    page <- tryCatch(readr::read_csv(
      I(body),
      show_col_types = FALSE,
      col_types = readr::cols(.default = readr::col_character()),
      progress = FALSE
    ), error = function(e) NULL)
    required <- c("GEOGRAPHY_CODE", "C2021_ETH_20_CODE", "OBS_VALUE")
    if (cross) required <- c(required, "C2021_AGE_6_CODE", "C_SEX_CODE")
    if (is.null(page) || !all(required %in% names(page))) {
      cli::cli_inform("NOMIS table is unavailable or has changed its schema.")
      return(NULL)
    }
    page <- page[required]
    expected <- length(chunk) * 19L * if (cross) 10L else 1L
    if (nrow(page) != expected || anyDuplicated(page[setdiff(
      required,
      "OBS_VALUE"
    )]) || !setequal(page$GEOGRAPHY_CODE, chunk)) {
      cli::cli_inform("NOMIS returned incomplete or duplicate cells.")
      return(NULL)
    }
    pages[[length(pages) + 1L]] <- page
  }
  raw <- dplyr::bind_rows(pages)
  mapping <- sl_table("nomis-ethnicity.csv")
  ix <- match(raw$C2021_ETH_20_CODE, mapping$nomis_code)
  result <- tibble::tibble(
    geography_code = raw$GEOGRAPHY_CODE,
    ethnicity = mapping[[paste0("ethnicity_", classification)]][ix],
    population = suppressWarnings(as.numeric(raw$OBS_VALUE))
  )
  if (cross) {
    result$age_band <- c("under 25", "25-34", "35+", "35+", "35+")[
      as.integer(sub("^_", "", raw$C2021_AGE_6_CODE))
    ]
    result$sex <- c("Female", "Male")[
      as.integer(sub("^_", "", raw$C_SEX_CODE))
    ]
  }
  if (anyNA(result)) {
    cli::cli_inform("Population cells are suppressed or unmapped; unavailable.")
    return(NULL)
  }
  keys <- setdiff(names(result), "population")
  result <- dplyr::summarise(
    dplyr::group_by(
      result,
      dplyr::across(dplyr::all_of(keys))
    ),
    population = sum(.data$population), .groups = "drop"
  )
  unknown <- unique(result[setdiff(keys, "ethnicity")])
  unknown$ethnicity <- "Unknown"
  unknown$population <- NA_real_
  result <- sl_exposure(dplyr::bind_rows(result, unknown), type, classification,
    source = "ONS Census 2021 via NOMIS"
  )
  contract <- sl_contract(result)
  contract$population <- list(
    source = "NOMIS", table_id = table, vintage = "2021-03-21",
    classification = classification, geography = type, retrieved = Sys.time(),
    codes = codes, url = "https://www.nomisweb.co.uk/api/v01/",
    cross_tabulation = cross
  )
  result <- sl_carry(result, contract, "sl_exposure")
  sl_prepare_cache(dir)
  saveRDS(result, path)
  result
}
