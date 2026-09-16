#' Directly standardise age-sex stop-event rates
#'
#' Uses common age-sex weights across ethnicity groups. Census sex is compared
#' with police-recorded gender only under an explicit measurement assumption.
#' Unknown age, gender and ethnicity are retained in exclusion diagnostics.
#' A positively weighted stratum with zero exposure makes the standardised rate
#' undefined; it is never silently dropped. Sampling intervals combine exact
#' Poisson stratum intervals with a Bonferroni correction and fixed weights.
#' They are conservative, including when every observed stratum count is zero.
#' @param counts Counts grouped by age_band and sex.
#' @param crosstab Compatible Census or explicit ethnicity-age-sex exposure.
#' @param standard England/Wales Census 2021 or pooled study population weights.
#' @param per Rate scaling, default 1000 per person-year.
#' @return An sl_sensitivity tibble with crude and standardised rates, sampling
#'   intervals, excluded-event counts, weights and the ingestion contract.
#' @family sensitivity
#' @seealso [sl_population_crosstab()], [sl_rates()]
#' @export
#' @examples
#' p <- readRDS(system.file("extdata", "sample-crosstab.rds",
#'   package = "searchlight"
#' ))
#' c <- readRDS(system.file("extdata", "example-demographic-counts.rds",
#'   package = "searchlight"
#' ))
#' head(suppressWarnings(sl_standardise(c, p)))
sl_standardise <- function(counts, crosstab,
                           standard = c("england_wales", "study_population"),
                           per = 1000) {
  standard <- match.arg(standard)
  sl_require_columns(counts, c("age_band", "sex"))
  sl_require_columns(crosstab, c("age_band", "sex"))
  contract <- sl_contract(counts)
  source <- if (standard == "study_population") {
    crosstab[crosstab$geography_code %in% counts$geography_code, ]
  } else {
    readRDS(system.file("extdata", "standard-population.rds",
      package = "searchlight"
    ))
  }
  source <- tibble::as_tibble(source)
  source <- source[source$ethnicity != "Unknown", ]
  groups <- dplyr::group_by(source, .data$age_band, .data$sex)
  weights <- dplyr::summarise(groups,
    weight = sum(.data$population), .groups = "drop"
  )
  if (!nrow(weights) || sum(weights$weight) <= 0) sl_abort("Empty standard.")
  weights$weight <- weights$weight / sum(weights$weight)
  collapsed <- sl_collapse_counts(counts, c("age_band", "sex"))
  rates <- sl_rates(collapsed, crosstab, per)
  rates <- dplyr::left_join(tibble::as_tibble(rates), weights,
    by = c("age_band", "sex")
  )
  excluded <- rates[is.na(rates$weight) | rates$ethnicity == "Unknown", ]
  excluded <- dplyr::summarise(
    dplyr::group_by(
      excluded, .data$force_id,
      .data$geography_code
    ),
    excluded_events = sum(.data$n, na.rm = TRUE),
    .groups = "drop"
  )
  known <- rates[rates$ethnicity != "Unknown" & !is.na(rates$weight), ]
  cells <- dplyr::summarise(
    dplyr::group_by(
      known, .data$force_id,
      .data$geography_code, .data$ethnicity, .data$age_band, .data$sex
    ),
    n = if (all(is.na(.data$n))) NA_real_ else sum(.data$n, na.rm = TRUE),
    exposure = sum(.data$exposure, na.rm = TRUE),
    weight = dplyr::first(.data$weight),
    .groups = "drop"
  )
  groups <- dplyr::group_split(dplyr::group_by(
    cells, .data$force_id,
    .data$geography_code, .data$ethnicity
  ))
  rows <- lapply(groups, function(x) {
    valid <- x$exposure > 0 & is.finite(x$exposure) & !is.na(x$n)
    complete <- all(valid | x$weight == 0) &&
      abs(sum(x$weight) - 1) < 1e-8
    crude <- if (sum(x$exposure) > 0) {
      sum(x$n, na.rm = TRUE) / sum(x$exposure) * per
    } else {
      NA_real_
    }
    rate <- lower <- upper <- NA_real_
    if (complete) {
      use <- valid & x$weight > 0
      rate <- sum(x$weight[use] * x$n[use] / x$exposure[use]) * per
      alpha <- 0.05 / sum(use)
      low <- ifelse(x$n[use] == 0, 0,
        stats::qchisq(alpha / 2, 2 * x$n[use]) / (2 * x$exposure[use])
      )
      high <- stats::qchisq(1 - alpha / 2, 2 * (x$n[use] + 1)) /
        (2 * x$exposure[use])
      lower <- sum(x$weight[use] * low) * per
      upper <- sum(x$weight[use] * high) * per
    }
    tibble::tibble(
      force_id = x$force_id[1], geography_code = x$geography_code[1],
      ethnicity = x$ethnicity[1], crude_rate = crude, standardised_rate = rate,
      conf_low = lower, conf_high = upper,
      complete_strata = complete, standard = standard
    )
  })
  result <- dplyr::left_join(dplyr::bind_rows(rows), excluded,
    by = c("force_id", "geography_code")
  )
  result$excluded_events[is.na(result$excluded_events)] <- 0
  result <- sl_sensitivity(
    result, contract,
    "conf_low/conf_high combine simultaneous exact Poisson stratum intervals",
    "not evaluated; one declared standard population"
  )
  attr(result, "weights") <- weights
  result
}
