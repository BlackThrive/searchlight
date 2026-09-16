#' Fetch a versioned ONS boundary layer
#'
#' Uses a verified catalogue; latest means the latest verified vintage in the
#' installed catalogue, not an unrecorded live change. Boundaries are BGC (20 m
#' generalised, coast clipped). Region polygons cover England. Census hierarchy
#' and current administrative lookups are attached with separate vintages.
#' @param type One of lsoa21, msoa21, ward, lad, pfa, region.
#' @param vintage A catalogue vintage (YYYY-MM), or latest.
#' @param dir Explicit cache directory.
#' @param codes Optional ONS codes to limit acquisition.
#' @param lookups Fetch and attach the ONS lookup tables.
#' @return An sf object with `geography_code`, `geography_name`, source metadata
#'   and lookups, or NULL with a message when the source is unavailable.
#' @family ingest
#' @seealso [sl_assign_geography()], [sl_population()]
#' @export
#' @examples
#' boundaries <- readRDS(system.file("extdata", "sample-boundaries.rds",
#'   package = "searchlight"
#' ))
#' boundaries$lsoa21[1, "geography_code"]
sl_boundaries <- function(type, vintage = "latest", dir = sl_cache_dir(),
                          codes = NULL, lookups = TRUE) {
  catalogue <- sl_table("ons-layers.csv")
  layer <- catalogue[catalogue$type == type, ]
  if (nrow(layer) != 1L) sl_abort("Unknown boundary type.")
  if (vintage != "latest" && vintage != layer$vintage) {
    sl_abort("Vintage is not in the verified catalogue.")
  }
  if (!is.null(codes)) codes <- sort(unique(codes))
  sl_codes_where(layer$code_field, codes)
  selection <- list(type, layer$vintage, codes, lookups)
  key <- digest::digest(selection, algo = "sha256")
  path <- file.path(dir, paste0("boundaries-", key, ".rds"))
  if (file.exists(path)) {
    return(readRDS(path))
  }
  metadata <- sl_json_get(paste0(sl_arc_base(layer$service), "?f=json"))
  if (is.null(metadata)) {
    return(NULL)
  }
  chunks <- if (is.null(codes)) {
    list(NULL)
  } else {
    split(
      codes,
      ceiling(seq_along(codes) / 100)
    )
  }
  pages <- list()
  for (chunk in chunks) {
    offset <- 0L
    repeat {
      where <- if (is.null(chunk)) {
        paste0(
          "(", layer$code_field, " LIKE 'E%' OR ",
          layer$code_field, " LIKE 'W%')"
        )
      } else {
        sl_codes_where(layer$code_field, chunk)
      }
      url <- sl_query_url(paste0(sl_arc_base(layer$service), "/query"), list(
        f = "geojson", where = where, outFields = "*", outSR = 4326,
        orderByFields = metadata$objectIdField,
        resultOffset = offset, resultRecordCount = 500
      ))
      response <- sl_get(url)
      if (is.null(response)) {
        return(NULL)
      }
      body <- httr2::resp_body_string(response)
      doc <- jsonlite::fromJSON(body, simplifyVector = FALSE)
      if (!is.null(doc$error) || !identical(doc$type, "FeatureCollection")) {
        cli::cli_inform("Boundary query unavailable for {type}.")
        return(NULL)
      }
      if (!length(doc$features)) break
      page <- sf::st_read(body, quiet = TRUE)
      pages[[length(pages) + 1L]] <- page
      offset <- offset + nrow(page)
      if (nrow(page) < 500L) break
    }
  }
  if (!length(pages)) {
    cli::cli_inform("No boundaries available for the requested codes.")
    return(NULL)
  }
  result <- do.call(rbind, pages)
  result$geography_code <- result[[layer$code_field]]
  result$geography_name <- result[[layer$name_field]]
  if (anyDuplicated(result$geography_code)) {
    sl_abort("Boundary source returned duplicate geography codes.", "source")
  }
  if (!is.null(codes) && !setequal(codes, result$geography_code)) {
    sl_warn("Some requested geography codes have no boundary.", "geography")
  }
  attr(result, "geography_metadata") <- list(
    type = type, layer_id = layer$item_id, service_layer = 0L,
    vintage = layer$vintage, crs = sf::st_crs(result)$input,
    retrieved = Sys.time(), url = sl_arc_base(layer$service),
    generalisation_m = 20
  )
  if (lookups) attr(result, "lookups") <- sl_lookups(dir)
  sl_prepare_cache(dir)
  saveRDS(result, path)
  result
}

#' @noRd
sl_lookups <- function(dir) {
  path <- file.path(dir, "ons-lookups.rds")
  if (file.exists(path)) {
    return(readRDS(path))
  }
  hierarchy <- sl_arc_table(
    "OA_LSOA_MSOA_EW_DEC_2021_LU_v3",
    c("LSOA21CD", "MSOA21CD", "LAD22CD")
  )
  if (is.null(hierarchy)) {
    return(NULL)
  }
  lad_pfa <- sl_arc_table(
    "LAD25_CSP25_PFA25_EW_LU",
    c("LAD25CD", "PFA25CD", "PFA25NM")
  )
  ward_lad <- sl_arc_table(
    "WD26_LAD26_UK_LU", c("WD26CD", "LAD26CD"),
    "WD26CD LIKE 'E%' OR WD26CD LIKE 'W%'"
  )
  region <- sl_arc_table(
    "LSOA21_BUA22_LAD22_RGN22_EW_LU_v2",
    c("LSOA21CD", "LAD22CD", "RGN22CD")
  )
  if (any(vapply(list(lad_pfa, ward_lad, region), is.null, logical(1)))) {
    return(NULL)
  }
  result <- list(
    census_hierarchy = hierarchy, lad_pfa = lad_pfa,
    ward_lad = ward_lad, lsoa_region = region,
    vintages = c(
      census_hierarchy = "2021-LSOA/MSOA; 2022-LAD",
      lad_pfa = "2025-04", ward_lad = "2026-05", lsoa_region = "2022-12"
    ), retrieved = Sys.time()
  )
  sl_prepare_cache(dir)
  saveRDS(result, path)
  result
}

#' Assign anonymised points to local geographies
#'
#' Uses British National Grid (EPSG:27700). Missing or invalid coordinates are
#' retained with NA assignments. On shared polygon edges, ties are resolved by
#' code and flagged ambiguous. Boundary distances describe anonymised snap
#' points, not the unknown true locations; resulting error may be systematic.
#' @param records Contract-bearing records.
#' @param boundaries A named list of sf layers, or one sf layer with metadata.
#' @param types Names of the layers to assign; defaults to supplied layers.
#' @param threshold Boundary-sensitive distance in metres.
#' @return Records with geography codes, per-layer distances and flags, and an
#'   updated contract. No event rows are dropped or duplicated.
#' @family ingest
#' @seealso [sl_boundaries()], [sl_location_quality()]
#' @export
#' @examples
#' b <- readRDS(system.file("extdata", "sample-boundaries.rds",
#'   package = "searchlight"
#' ))
#' x <- sl_sample()[1:3, ]
#' b$msoa21 <- b$msoa21[b$msoa21$geography_code %in% x$msoa21, ]
#' sl_assign_geography(x, b, "msoa21")
sl_assign_geography <- function(records, boundaries,
                                types = names(boundaries), threshold = 50) {
  contract <- sl_contract(records)
  invalid <- !is.numeric(threshold) || length(threshold) != 1L ||
    !is.finite(threshold) || threshold < 0
  if (invalid) {
    sl_abort("Invalid boundary threshold.")
  }
  if (inherits(boundaries, "sf")) {
    type <- attr(boundaries, "geography_metadata")$type
    if (is.null(type)) sl_abort("A single boundary layer needs type metadata.")
    boundaries <- stats::setNames(list(boundaries), type)
    if (missing(types)) types <- type
  }
  if (!length(types) || any(!types %in% names(boundaries))) {
    sl_abort("Every requested type needs a named boundary layer.")
  }
  sl_require_columns(records, c("latitude", "longitude"))
  valid <- sl_valid_coordinates(records)
  result <- records
  points <- if (any(valid)) {
    sf::st_transform(sf::st_as_sf(
      as.data.frame(records[valid, ]),
      coords = c("longitude", "latitude"),
      crs = 4326
    ), 27700)
  } else {
    NULL
  }
  for (type in types) {
    polygons <- boundaries[[type]]
    sl_require_columns(polygons, "geography_code")
    invalid <- anyDuplicated(polygons$geography_code) ||
      is.na(sf::st_crs(polygons))
    if (invalid) {
      sl_abort("Invalid boundary codes or CRS.")
    }
    polygons <- sf::st_transform(sf::st_make_valid(polygons), 27700)
    polygons <- polygons[order(polygons$geography_code), ]
    codes <- rep(NA_character_, nrow(records))
    distance <- rep(NA_real_, nrow(records))
    ambiguous <- rep(FALSE, nrow(records))
    if (!is.null(points)) {
      hits <- sf::st_intersects(points, polygons)
      match <- vapply(
        hits, function(x) if (length(x)) x[1] else NA_integer_,
        integer(1)
      )
      codes[valid] <- polygons$geography_code[match]
      ambiguous[valid] <- lengths(hits) > 1L
      inside <- which(!is.na(match))
      if (length(inside)) {
        edge <- sf::st_boundary(sf::st_geometry(polygons[match[inside], ]))
        distance[which(valid)[inside]] <- as.numeric(sf::st_distance(
          points[inside, ], edge,
          by_element = TRUE
        ))
      }
    }
    result[[type]] <- codes
    result[[paste0(type, "_boundary_distance_m")]] <- distance
    result[[paste0(type, "_boundary_sensitive")]] <- distance < threshold
    result[[paste0(type, "_ambiguous")]] <- ambiguous
    metadata <- attr(boundaries[[type]], "geography_metadata")
    if (is.null(metadata)) {
      metadata <- list(type = type, source = "user_supplied")
    }
    metadata$assignment_crs <- "EPSG:27700"
    metadata$threshold_m <- threshold
    contract$geography[[type]] <- metadata
    quality <- tibble::tibble(
      type = type, missing_coordinate_share = sl_mean(!valid),
      unassigned_share = sl_mean(is.na(codes)),
      boundary_sensitive_share = if (all(is.na(distance))) {
        NA_real_
      } else {
        mean(distance < threshold, na.rm = TRUE)
      },
      ambiguous_share = sl_mean(ambiguous), threshold_m = threshold
    )
    previous <- contract$assignment_quality
    if (nrow(previous)) previous <- previous[previous$type != type, ]
    contract$assignment_quality <- dplyr::bind_rows(previous, quality)
  }
  sl_carry(result, contract, "sl_records")
}
