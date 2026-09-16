#' Diagnose timestamp completeness and midnight heaping
#'
#' Reports both London-clock midnight and midnight in the source string. Some
#' date-only summer records carry a UTC offset, so checking London midnight
#' alone would miss them. Reliability requires both shares below threshold and
#' no missing timestamps. This is a screening diagnostic, not proof that all
#' supplied times are accurate. Empty and absent force-months are not reliable.
#' @param records Contract-bearing records.
#' @param threshold Maximum permitted midnight share, default 0.05.
#' @return A tibble with force-month diagnostics and within-force share range.
#' @family audit
#' @seealso [sl_quality()], [sl_location_quality()]
#' @export
#' @examples
#' sl_timestamp_quality(sl_sample())
sl_timestamp_quality <- function(records, threshold = 0.05) {
  contract <- sl_contract(records)
  invalid <- length(threshold) != 1L || !is.finite(threshold) ||
    threshold < 0 || threshold > 1
  if (invalid) {
    sl_abort("Invalid midnight threshold.")
  }
  result <- sl_time_summary(records, threshold)
  grid <- unique(contract$coverage[c("force_id", "month")])
  result <- dplyr::left_join(grid, result, by = c("force_id", "month"))
  result$time_reliable[is.na(result$time_reliable)] <- FALSE
  result$force_midnight_range <- NA_real_
  for (force in unique(result$force_id)) {
    ix <- which(result$force_id == force)
    values <- result$gating_midnight_share[ix]
    if (any(is.finite(values))) {
      result$force_midnight_range[ix] <- diff(range(values, na.rm = TRUE))
    }
  }
  contract$timestamps <- result
  sl_carry(result, contract)
}

#' Diagnose anonymised location quality
#'
#' Snap-point concentration is the share at the most common reported coordinate
#' within an LSOA, among records with usable coordinates in that LSOA. It is not
#' the concentration at true incident locations. Missing LSOA assignments remain
#' a separate group. Per-geography boundary diagnostics remain in the contract.
#' @param records Contract-bearing records, optionally with assigned LSOAs.
#' @return A force-month-LSOA tibble with missingness, concentration and
#'   boundary sensitivity, carrying the contract.
#' @family audit
#' @seealso [sl_assign_geography()], [sl_timestamp_quality()]
#' @export
#' @examples
#' sl_location_quality(sl_sample()[1:100, ])
sl_location_quality <- function(records) {
  contract <- sl_contract(records)
  sl_require_columns(records, c("force_id", "month", "latitude", "longitude"))
  x <- tibble::as_tibble(records)
  if (!"lsoa21" %in% names(x)) x$lsoa21 <- NA_character_
  x$valid_coordinate <- sl_valid_coordinates(x)
  x$coordinate <- paste(x$latitude, x$longitude, sep = ",")
  x$coordinate[!x$valid_coordinate] <- NA_character_
  if (!"lsoa21_boundary_sensitive" %in% names(x)) {
    x$lsoa21_boundary_sensitive <- NA
  }
  grouped <- dplyr::group_by(x, .data$force_id, .data$month, .data$lsoa21)
  result <- dplyr::summarise(grouped,
    n_records = dplyr::n(),
    missing_coordinate_share = mean(!.data$valid_coordinate),
    snap_point_concentration = sl_concentration(.data$coordinate),
    boundary_sensitive_share = sl_mean(.data$lsoa21_boundary_sensitive),
    .groups = "drop"
  )
  sl_carry(result, contract)
}

#' @noRd
sl_concentration <- function(coordinates) {
  counts <- table(coordinates, useNA = "no")
  if (!length(counts)) NA_real_ else max(counts) / sum(counts)
}

#' Attach submission, timestamp and location diagnostics
#'
#' Pass population to complete the population metadata in the records contract;
#' population counts remain a separate exposure table. Diagnostics describe the
#' current records; coverage continues to describe the original source files.
#' @param records Contract-bearing records.
#' @param population Optional sl_exposure table.
#' @param threshold Midnight-share threshold.
#' @param changelog Optional changelog table passed to sl_coverage.
#' @return Records with an updated contract and attached quality tables.
#' @family audit
#' @seealso [sl_coverage()], [sl_timestamp_quality()], [sl_location_quality()]
#' @export
#' @examples
#' records <- sl_quality(sl_sample()[1:100, ])
#' sl_contract(records)$timestamps
sl_quality <- function(records, population = NULL, threshold = 0.05,
                       changelog = NULL) {
  contract <- sl_contract(records)
  contract$coverage <- tibble::as_tibble(sl_coverage(records,
    changelog = changelog
  ))
  contract$timestamps <- tibble::as_tibble(sl_timestamp_quality(
    records,
    threshold
  ))
  contract$location_quality <- tibble::as_tibble(sl_location_quality(records))
  if (!is.null(population)) {
    contract$population <- sl_contract(population)$population
  }
  sl_carry(records, contract, "sl_records")
}

#' @noRd
sl_valid_coordinates <- function(records) {
  is.finite(records$latitude) & is.finite(records$longitude) &
    records$latitude >= 49 & records$latitude <= 61 &
    records$longitude >= -9 & records$longitude <= 3
}

#' @noRd
sl_mean <- function(x) {
  if (!length(x) || all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
}
