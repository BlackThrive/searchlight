#' Read selected immutable archive records
#'
#' Validates the fixed CSV schema, checksum and row count, preserving
#' every event
#' (including identical rows) and raw ethnicity strings. Timestamps
#' retain their
#' supplied UTC offsets and are displayed in Europe/London. Absent or refused
#' ethnicity is Unknown. Missing outcome measures remain NA, not negative
#' outcomes.
#' @param dir Snapshot cache directory.
#' @param versions One selected version per force-month; defaults to latest.
#' @return An `sl_records` tibble with a validated ingestion contract.
#' @family ingest
#' @seealso [sl_contract()], [sl_select_version()], [sl_sample()]
#' @export
#' @examples
#' d <- system.file("extdata", "sample", package = "searchlight")
#' v <- sl_select_version(sl_list_versions(d))
#' records <- sl_read_records(d, v[1, ])
#' summary(sl_contract(records))
sl_read_records <- function(dir = sl_cache_dir(), versions = NULL) {
  if (is.null(versions)) versions <- sl_select_version(sl_list_versions(dir))
  sl_require_columns(versions, c(
    "force_id", "month", "archive_file", "csv_path", "csv_sha256",
    "n_records", "alternatives", "selection_rule"
  ))
  if (anyDuplicated(paste(versions$force_id, versions$month))) {
    sl_abort(
      "Select exactly one version per force-month before parsing.",
      "versions"
    )
  }
  schema <- c(
    "Type", "Date", "Part of a policing operation", "Policing operation",
    "Latitude", "Longitude", "Gender", "Age range", "Self-defined ethnicity",
    "Officer-defined ethnicity", "Legislation", "Object of search", "Outcome",
    "Outcome linked to object of search",
    "Removal of more than just outer clothing"
  )
  records <- lapply(seq_len(nrow(versions)), function(i) {
    path <- file.path(dir, versions$csv_path[i])
    if (!file.exists(path) || !identical(
      sl_hash(path),
      versions$csv_sha256[i]
    )) {
      sl_abort(
        "Selected CSV is missing or fails its recorded SHA-256.", "integrity"
      )
    }
    x <- readr::read_csv(path,
      col_types = readr::cols(.default = readr::col_character()),
      show_col_types = FALSE, progress = FALSE, name_repair = "minimal"
    )
    if (!identical(names(x), schema) || nrow(x) != versions$n_records[i]) {
      sl_abort("CSV schema or row count differs from its contract.", "schema")
    }
    names(x) <- gsub("[^a-z0-9]+", "_", tolower(names(x)))
    names(x)[names(
      x
    ) == "self_defined_ethnicity"] <- "self_defined_ethnicity_raw"
    x$date_raw <- x$date
    x$date <- readr::parse_datetime(x$date_raw,
      locale = readr::locale(tz = "Europe/London"), na = c("", "NA")
    )
    if (any(!is.na(x$date_raw) & is.na(x$date))) {
      sl_abort("Unparseable timestamp in selected CSV.", "schema")
    }
    for (column in c("latitude", "longitude")) {
      value <- suppressWarnings(readr::parse_double(x[[column]]))
      if (any(!is.na(x[[column]]) & is.na(value))) {
        sl_abort(paste("Unparseable", column, "in selected CSV."), "schema")
      }
      x[[column]] <- value
    }
    x$part_of_a_policing_operation <- sl_bool(x$part_of_a_policing_operation)
    x$force_id <- rep(versions$force_id[i], nrow(x))
    x$month <- rep(versions$month[i], nrow(x))
    record_month <- format(x$date, "%Y-%m", tz = "Europe/London")
    if (any(!is.na(x$date) & record_month != x$month)) {
      sl_abort(
        "Record timestamp does not belong to its filename month.", "schema"
      )
    }
    x
  })
  result <- sl_classify_records(tibble::as_tibble(dplyr::bind_rows(records)))
  levels_by_column <- list(
    type = c(
      "Person search", "Vehicle search",
      "Person and Vehicle search", "Unknown"
    ),
    gender = c("Female", "Male", "Other", "Unknown"),
    age_range = c("under 10", "10-17", "18-24", "25-34", "over 34", "Unknown")
  )
  for (column in names(levels_by_column)) {
    value <- result[[column]]
    value[is.na(value) | !value %in% levels_by_column[[column]]] <- "Unknown"
    result[[column]] <- factor(value, levels_by_column[[column]])
  }
  contract <- sl_new_contract()
  contract$snapshots <- unique(versions[c(
    "archive_file", "archive_sha256", "downloaded_at", "url"
  )])
  names(contract$snapshots)[2] <- "sha256"
  contract$versions <- versions
  manifest_path <- file.path(dir, "archive-manifest.rds")
  contract$requested <- unique(versions[c("force_id", "month")])
  if (file.exists(manifest_path)) {
    requests <- readRDS(manifest_path)
    grids <- lapply(seq_len(nrow(requests)), function(i) {
      forces <- requests$requested_forces[[i]]
      if (is.null(forces)) {
        forces <- jsonlite::fromJSON(system.file(
          "extdata", "forces.json",
          package = "searchlight"
        ))$id
      }
      expand.grid(
        force_id = forces, month = requests$requested_months[[i]],
        stringsAsFactors = FALSE
      )
    })
    contract$requested <- unique(dplyr::bind_rows(grids))
  }
  contract$coverage <- tibble::tibble(
    force_id = versions$force_id, month = versions$month,
    status = ifelse(vapply(
      versions$alternatives,
      function(v) length(unique(v$n_records)) > 1L, logical(1)
    ), "refreshed", "submitted"),
    n_records = versions$n_records, changelog_note = NA_character_
  )
  contract$timestamps <- sl_time_summary(result, 0.05)
  absent <- dplyr::anti_join(contract$requested, contract$coverage,
    by = c("force_id", "month")
  )
  if (nrow(absent)) {
    absent$status <- "missing"
    absent$n_records <- NA_integer_
    absent$changelog_note <- NA_character_
    contract$coverage <- dplyr::bind_rows(contract$coverage, absent)
  }
  sl_carry(result, contract, "sl_records")
}

#' Load the bundled real archive sample
#' @return An `sl_records` tibble for the documented sample forces and months.
#' @family ingest
#' @seealso [sl_read_records()], [sl_contract()]
#' @export
#' @examples
#' x <- sl_sample()
#' table(x$force_id, x$month)
sl_sample <- function() {
  readRDS(system.file("extdata", "sample-records.rds", package = "searchlight"))
}

#' @noRd
sl_time_summary <- function(records, threshold) {
  empty <- tibble::tibble(
    force_id = character(), month = character(),
    n_records = integer(), midnight_share = double(),
    source_midnight_share = double(), gating_midnight_share = double(),
    missing_time_share = double(), time_reliable = logical()
  )
  groups <- split(seq_len(nrow(records)), paste(
    records$force_id,
    records$month
  ))
  dplyr::bind_rows(lapply(groups, function(i) {
    x <- records[i, ]
    times <- format(x$date, "%H:%M:%S", tz = "Europe/London")
    missing <- mean(is.na(times))
    midnight <- if (all(is.na(times))) {
      NA_real_
    } else {
      mean(
        times == "00:00:00",
        na.rm = TRUE
      )
    }
    source_midnight <- if ("date_raw" %in% names(x)) {
      sl_mean(grepl("[T ]00:00:00", x$date_raw))
    } else {
      midnight
    }
    gating <- max(midnight, source_midnight)
    tibble::tibble(
      force_id = x$force_id[1], month = x$month[1], n_records = nrow(x),
      midnight_share = midnight, missing_time_share = missing,
      source_midnight_share = source_midnight, gating_midnight_share = gating,
      time_reliable = !is.na(gating) && gating < threshold && missing == 0
    )
  })) |> dplyr::bind_rows(empty)
}
