#' Count events while preserving submission strata
#'
#' Force and month always remain in the result, even if omitted from by: these
#' identify independent reporting and time-exposure cells. Unknown ethnicity
#' remains a level. Missing submissions have NA counts; submitted combinations
#' without events have zero. Filtering records does not narrow the source time
#' grid: pass months and forces explicitly to select the analysis period.
#' @param records Contract-bearing records.
#' @param by Additional grouping columns, including exactly one ethnicity field.
#' @param units Optional force_id and geography mapping defining the full area
#'   universe, including areas without events. Otherwise uses contract units or
#'   observed areas. PFA defaults to the published force-code mapping.
#' @param months,forces Explicit analysis scope; defaults to contract coverage.
#' @return An sl_counts tibble with canonical geography_code, ethnicity, n,
#'   force_id and month columns, original grouping fields, and coverage status.
#' @family rates
#' @seealso [sl_rates()], [sl_coverage()]
#' @export
#' @examples
#' counts <- sl_counts(sl_sample())
#' head(counts)
sl_counts <- function(records, by = c("pfa", "month", "ethnicity_5"),
                      units = NULL, months = NULL, forces = NULL) {
  contract <- sl_contract(records)
  if (is.null(months)) months <- unique(contract$coverage$month)
  if (is.null(forces)) forces <- unique(contract$coverage$force_id)
  months <- sl_months(months)
  ethnicity <- intersect(by, c(
    "ethnicity_5", "ethnicity_19",
    "ethnicity_officer"
  ))
  if (length(ethnicity) != 1L) {
    sl_abort("Select exactly one ethnicity grouping.")
  }
  geo <- intersect(by, c(
    "pfa", "lsoa21", "msoa21", "ward", "lad", "region",
    "geography_code"
  ))
  if (length(geo) != 1L) sl_abort("Select exactly one geography grouping.")
  x <- tibble::as_tibble(records)
  if ("age_band" %in% by) {
    age <- c(
      "under 25", "under 25", "under 25", "25-34", "35+",
      "Unknown"
    )[match(
      as.character(x$age_range),
      c("under 10", "10-17", "18-24", "25-34", "over 34", "Unknown")
    )]
    x$age_band <- factor(age, c("under 25", "25-34", "35+", "Unknown"))
  }
  if ("sex" %in% by) {
    x$sex <- factor(x$gender, c("Female", "Male", "Other", "Unknown"))
  }
  sl_require_columns(x, unique(c(by, "force_id", "month")))
  values <- as.character(x[[ethnicity]])
  values[is.na(values)] <- "Unknown"
  allowed <- if (ethnicity == "ethnicity_officer") {
    c("Asian", "Black", "Mixed", "White", "Other", "Unknown")
  } else {
    unique(sl_table("ethnicity.csv")[[ethnicity]])
  }
  if (any(!values %in% allowed)) sl_abort("Unrecognised ethnicity categories.")
  x[[ethnicity]] <- factor(values, allowed)
  x <- x[x$force_id %in% forces & x$month %in% months, ]
  scope <- contract$coverage
  scope <- scope[scope$force_id %in% forces & scope$month %in% months, ]
  expected <- tidyr::expand_grid(force_id = forces, month = months)
  scope <- dplyr::left_join(expected, scope, by = c("force_id", "month"))
  scope$status[is.na(scope$status)] <- "missing"
  if (is.null(units) && geo %in% names(contract$units)) units <- contract$units
  if (is.null(units) && geo == "pfa") {
    units <- sl_table("ppap-totals.csv")[c("force_id", "pfa_code")]
    names(units)[2] <- "pfa"
    units <- units[units$pfa != "0", ]
  }
  universe <- if (is.null(units)) "observed areas" else "explicit units"
  if (is.null(units)) units <- unique(x[c("force_id", geo)])
  sl_require_columns(units, c("force_id", geo))
  units <- unique(units[c("force_id", geo)])
  units <- units[units$force_id %in% forces, ]
  units <- unique(dplyr::bind_rows(units, x[c("force_id", geo)]))
  grid <- dplyr::left_join(scope[c("force_id", "month", "status")], units,
    by = "force_id", relationship = "many-to-many"
  )
  dimensions <- setdiff(by, c("force_id", "month", geo))
  for (dimension in dimensions) {
    values <- if (is.factor(x[[dimension]])) {
      levels(x[[dimension]])
    } else {
      sort(unique(x[[dimension]]))
    }
    if (dimension == ethnicity) values <- unique(c(values, "Unknown"))
    if (!length(values)) values <- "Unknown"
    grid <- merge(grid, stats::setNames(data.frame(values), dimension),
      by = NULL, sort = FALSE
    )
  }
  keys <- unique(c("force_id", "month", by))
  observed <- dplyr::count(x, dplyr::across(dplyr::all_of(keys)), name = "n")
  result <- dplyr::left_join(tibble::as_tibble(grid), observed, by = keys)
  missing <- result$status == "missing"
  if (any(missing & !is.na(result$n))) {
    sl_abort("Events occur in a force-month marked missing.", "contract")
  }
  result$n[is.na(result$n) & !missing] <- 0L
  result$geography_code <- as.character(result[[geo]])
  result$ethnicity <- as.character(result[[ethnicity]])
  result$months_submitted <- as.integer(!missing)
  contract$coverage <- scope
  contract$analysis <- list(
    geography = geo, ethnicity = ethnicity,
    classification = if (ethnicity == "ethnicity_19") "19" else "5",
    scheme = if (ethnicity == "ethnicity_officer") {
      "officer-defined"
    } else {
      "self-defined"
    }, area_universe = universe,
    strata = setdiff(keys, c("month", ethnicity))
  )
  sl_carry(result, contract, "sl_counts")
}

#' Calculate rates using observed population-time exposure
#'
#' The primary rate is annualised events per 1,000 resident person-years:
#' n / (population * submitted_months / 12) * per. The separate period_rate
#' is n / population * per for that cell. Neither is a probability of a person
#' being searched. NA submission counts are excluded from time exposure. Partial
#' submissions remain flagged and describe reported events only.
#' @param counts Output from sl_counts.
#' @param population A compatible sl_exposure table.
#' @param per Rate scaling, default 1000.
#' @return An sl_rates tibble with population, exposure, rate and period_rate.
#' @family rates
#' @seealso [sl_counts()], [sl_rate_ratio()], [sl_exposure()]
#' @export
#' @examples
#' c <- readRDS(system.file("extdata", "example-counts.rds",
#'   package = "searchlight"
#' ))
#' p <- readRDS(system.file("extdata", "sample-population.rds",
#'   package = "searchlight"
#' ))$msoa21
#' head(sl_rates(c, p))
sl_rates <- function(counts, population, per = 1000) {
  contract <- sl_contract(counts)
  metadata <- sl_contract(population)$population
  sl_require_columns(counts, c(
    "geography_code", "ethnicity", "n",
    "months_submitted", "status"
  ))
  n <- counts$n
  months <- counts$months_submitted
  valid_n <- is.numeric(n) &&
    all(is.na(n) | (is.finite(n) & n >= 0 & n == floor(n)))
  valid_time <- all(is.finite(months) & months >= 0 & months == floor(months))
  if (!valid_n || !valid_time) {
    sl_abort("Counts and submitted months must be valid.")
  }
  missing <- counts$status == "missing"
  contradictory <- (missing & (!is.na(n) | months != 0)) |
    (!missing & (is.na(n) | months == 0))
  if (any(contradictory)) sl_abort("Counts contradict submission status.")
  if (length(per) != 1L || !is.finite(per) || per <= 0) {
    sl_abort("Invalid scale.")
  }
  analysis <- contract$analysis
  incompatible <- is.null(analysis) ||
    analysis$classification != metadata$classification ||
    analysis$geography != metadata$geography ||
    analysis$scheme != "self-defined"
  if (incompatible) {
    sl_abort(
      "Exposure classification, geography or measurement is incompatible.",
      "population"
    )
  }
  if (any(counts$status == "missing")) {
    sl_warn("Missing force-months are excluded from time exposure.", "coverage")
  }
  if (any(counts$status == "partial_suspected")) {
    sl_warn(
      "Rates include suspected partial submissions; interpret cautiously.",
      "coverage"
    )
  }
  keys <- c("geography_code", "ethnicity")
  strata <- intersect(c("age_band", "sex"), names(population))
  if (!setequal(strata, intersect(c("age_band", "sex"), names(counts)))) {
    sl_abort("Age/sex count strata require matching exposure strata.")
  }
  keys <- c(keys, strata)
  if (anyDuplicated(population[keys])) sl_abort("Duplicate exposure keys.")
  p <- tibble::as_tibble(population)[c(keys, "population")]
  result <- dplyr::left_join(tibble::as_tibble(counts), p, by = keys)
  missing <- result$ethnicity != "Unknown" & result$months_submitted > 0 &
    !is.na(result$n) & result$n > 0 &
    is.na(result$population)
  if (any(missing)) {
    sl_warn(
      "Some assigned counts have no compatible population; rates are NA.",
      "population"
    )
  }
  if (any(result$n > 0 & result$population == 0, na.rm = TRUE)) {
    sl_warn(
      "Positive events with zero Census exposure have undefined rates.",
      "population"
    )
  }
  result$exposure <- result$population * result$months_submitted / 12
  usable <- is.finite(result$exposure) & result$exposure > 0
  result$rate <- result$period_rate <- NA_real_
  result$rate[usable] <- result$n[usable] / result$exposure[usable] * per
  period <- result$n[usable] / result$population[usable] * per
  result$period_rate[usable] <- period
  contract$population <- metadata
  contract$analysis$rate_scale <- per
  contract$analysis$time_unit <- "person-years; submitted months / 12"
  sl_carry(result, contract, "sl_rates")
}

#' Estimate an event stop-rate ratio with exposure offsets
#'
#' Fits n ~ ethnicity with log(population-time) offset within each area and
#' other grouping stratum, pooling submitted months. Poisson intervals are exact
#' conditional intervals for two event counts; zero counts are supported without
#' adding pseudocounts. Quasi-Poisson and negative binomial require replicated
#' cells and use model-based log intervals. Dispersion is Pearson chi-square
#' divided by residual degrees of freedom. This is not a person-level
#' risk ratio.
#' @param rates Output from sl_rates.
#' @param reference,comparison Self-defined ethnicity groups.
#' @param method Count model family.
#' @param conf_level Sampling confidence level.
#' @return An sl_rate_ratio tibble with sampling intervals, dispersion, counts,
#'   exposures and fitted model list column, carrying the ingestion contract.
#' @family rates
#' @seealso [sl_rates()], [sl_missing_ethnicity_bounds()]
#' @export
#' @examples
#' r <- readRDS(system.file("extdata", "example-rates.rds",
#'   package = "searchlight"
#' ))
#' head(sl_rate_ratio(r))
sl_rate_ratio <- function(rates, reference = "White", comparison = "Black",
                          method = c("poisson", "quasipoisson", "negbin"),
                          conf_level = 0.95) {
  method <- match.arg(method)
  contract <- sl_contract(rates)
  sl_require_columns(rates, c("geography_code", "ethnicity", "n", "exposure"))
  sl_validate_pair(reference, comparison, conf_level)
  strata <- unique(c(contract$analysis$strata, "geography_code"))
  strata <- intersect(strata, names(rates))
  groups <- dplyr::group_split(dplyr::group_by(
    tibble::as_tibble(rates),
    dplyr::across(dplyr::all_of(strata))
  ))
  rows <- lapply(groups, function(group) {
    selected <- group$ethnicity %in% c(reference, comparison) &
      is.finite(group$exposure) & group$exposure > 0 & !is.na(group$n)
    d <- group[selected, ]
    fit <- sl_pair_fit(d, reference, comparison, method, conf_level)
    excluded <- group$ethnicity %in% c(reference, comparison) & !selected
    fit$excluded_pair_events <- sum(group$n[excluded], na.rm = TRUE)
    unknown <- group$ethnicity == "Unknown"
    fit$unknown_events <- sum(group$n[unknown], na.rm = TRUE)
    if (all(is.na(group$n))) {
      fit$excluded_pair_events <- fit$unknown_events <- NA_real_
    }
    dplyr::bind_cols(group[1, strata, drop = FALSE], fit)
  })
  sl_carry(dplyr::bind_rows(rows), contract, "sl_rate_ratio")
}

#' @noRd
sl_validate_pair <- function(reference, comparison, level = 0.95) {
  invalid <- length(reference) != 1L || length(comparison) != 1L ||
    anyNA(c(reference, comparison)) || reference == comparison ||
    "Unknown" %in% c(reference, comparison)
  if (invalid) {
    sl_abort("Choose two distinct known ethnicity groups.")
  }
  if (length(level) != 1L || !is.finite(level) || level <= 0 || level >= 1) {
    sl_abort("Confidence level must be between zero and one.")
  }
}

#' @noRd
sl_pair_fit <- function(d, reference, comparison, method, level) {
  has_ref <- any(d$ethnicity == reference)
  has_cmp <- any(d$ethnicity == comparison)
  n_ref <- if (has_ref) sum(d$n[d$ethnicity == reference]) else NA_real_
  n_cmp <- if (has_cmp) sum(d$n[d$ethnicity == comparison]) else NA_real_
  e_ref <- sum(d$exposure[d$ethnicity == reference])
  e_cmp <- sum(d$exposure[d$ethnicity == comparison])
  fit <- NULL
  ratio <- low <- high <- dispersion <- NA_real_
  estimable <- has_ref && has_cmp && e_ref > 0 && e_cmp > 0 &&
    n_ref + n_cmp > 0
  if (estimable) {
    ratio <- (n_cmp / e_cmp) / (n_ref / e_ref)
    d$group <- factor(d$ethnicity, levels = c(reference, comparison))
    formula <- stats::as.formula("n ~ group + offset(log(exposure))")
    if (method == "poisson") {
      interval <- stats::poisson.test(c(n_cmp, n_ref),
        T = c(e_cmp, e_ref),
        conf.level = level
      )$conf.int
      low <- interval[1]
      high <- interval[2]
      if (n_ref > 0 && n_cmp > 0) {
        fit <- stats::glm(formula, data = d, family = stats::poisson())
      }
    } else {
      if (nrow(d) <= 2L || n_ref == 0 || n_cmp == 0) {
        sl_abort(
          "Quasi-Poisson/negbin need replicated positive group counts.",
          "model"
        )
      }
      fit <- if (method == "negbin") {
        MASS::glm.nb(formula, data = d)
      } else {
        stats::glm(formula, data = d, family = stats::quasipoisson())
      }
      beta <- stats::coef(fit)[2]
      se <- sqrt(stats::vcov(fit)[2, 2])
      z <- if (method == "quasipoisson") {
        stats::qt(1 - (1 - level) / 2, df = fit$df.residual)
      } else {
        stats::qnorm(1 - (1 - level) / 2)
      }
      ratio <- exp(beta)
      low <- exp(beta - z * se)
      high <- exp(beta + z * se)
    }
    if (!is.null(fit) && fit$df.residual > 0) {
      dispersion <- sum(stats::residuals(fit, type = "pearson")^2) /
        fit$df.residual
    }
  }
  tibble::tibble(
    reference = reference, comparison = comparison,
    ratio = unname(ratio), conf_low = unname(low), conf_high = unname(high),
    conf_level = level, method = method, dispersion = dispersion,
    n_reference = n_ref, n_comparison = n_cmp,
    exposure_reference = e_ref, exposure_comparison = e_cmp,
    estimable = estimable, model = list(fit)
  )
}
