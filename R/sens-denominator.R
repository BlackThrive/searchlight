#' Compare compatible population denominator scenarios
#'
#' Exposure tables must have identical geography/classification and cell keys.
#' Each sampling interval is conditional on its exposure scenario; the range of
#' point estimates across scenarios is reported separately.
#' @param counts Contract-bearing event counts.
#' @param exposures Named list of sl_exposure tables.
#' @param reference,comparison Groups to compare.
#' @return An sl_sensitivity tibble with scenario ratios and assumption ranges.
#' @family sensitivity
#' @seealso [sl_exposure()], [sl_missing_ethnicity_bounds()]
#' @export
#' @examples
#' p <- readRDS(system.file("extdata", "sample-population.rds",
#'   package = "searchlight"
#' ))$msoa21
#' c <- readRDS(system.file("extdata", "example-counts.rds",
#'   package = "searchlight"
#' ))
#' head(sl_denominator_scenarios(c, list(resident = p)))
sl_denominator_scenarios <- function(counts, exposures, reference = "White",
                                     comparison = "Black") {
  invalid <- !is.list(exposures) || !length(exposures) ||
    is.null(names(exposures)) || any(names(exposures) == "") ||
    anyDuplicated(names(exposures))
  if (invalid) {
    sl_abort("Supply uniquely named exposure scenarios.")
  }
  metadata <- lapply(exposures, function(p) sl_contract(p)$population)
  first <- metadata[[1]]
  key <- function(p) {
    if (any(c("age_band", "sex") %in% names(p))) {
      sl_abort("Denominator scenarios require marginal ethnicity exposures.")
    }
    sort(paste(p$geography_code, p$ethnicity))
  }
  for (i in seq_along(exposures)) {
    same <- identical(metadata[[i]]$classification, first$classification) &&
      identical(metadata[[i]]$geography, first$geography) &&
      identical(key(exposures[[i]]), key(exposures[[1]]))
    if (!same) {
      sl_abort("Exposure scenarios have incompatible cells or schemes.")
    }
  }
  collapsed <- sl_collapse_counts(counts)
  rows <- lapply(names(exposures), function(scenario) {
    ratios <- sl_rate_ratio(
      sl_rates(collapsed, exposures[[scenario]]),
      reference, comparison
    )
    ratios$scenario <- scenario
    tibble::as_tibble(ratios)
  })
  result <- dplyr::bind_rows(rows)
  result <- dplyr::group_by(result, .data$force_id, .data$geography_code)
  result <- dplyr::mutate(result,
    lower_bound = if (all(is.na(.data$ratio))) {
      NA_real_
    } else {
      min(.data$ratio, na.rm = TRUE)
    },
    upper_bound = if (all(is.na(.data$ratio))) {
      NA_real_
    } else {
      max(.data$ratio, na.rm = TRUE)
    }
  )
  sl_sensitivity(
    dplyr::ungroup(result), sl_contract(counts),
    "conf_low/conf_high are conditional on each exposure scenario",
    "lower_bound/upper_bound span scenario point estimates only"
  )
}
