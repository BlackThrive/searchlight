#' Fit count models with population-time exposure
#'
#' Models recorded events, never unique people or a population-minus-stops
#'   cell.
#' A population offset is multiplied by months_submitted/12 when available.
#' Other offset columns must already represent exposure over the observed
#'   period.
#' Unknown ethnicity and rows without positive exposure are reported as
#'   exclusions.
#' Moran's I uses mean Pearson residuals per area and is exploratory after
#'   fitting.
#' The exponentiated intercept is a baseline rate per exposure unit; other
#' exponentiated coefficients are multiplicative rate effects. Confidence
#' bounds are reported on this exponentiated scale.
#' @param counts Counts with a contract and exposure column, usually sl_rates.
#' @param formula A formula with response n and desired fixed predictors.
#' @param family Poisson or negative binomial.
#' @param offset Name of the population or population-time exposure column.
#' @param random Optional one-sided lme4 formula, for example ~ (1 |
#'   force_id).
#' @param boundaries Optional sf polygons keyed by geography_code for
#'   residuals.
#' @param conf_level Wald confidence level.
#' @return A tidy sl_count_model coefficient table with model, diagnostics and
#'   excluded row/event counts in attributes, carrying the ingestion contract.
#' @family inference
#' @seealso [sl_rates()], [sl_spatial_disparity()]
#' @export
#' @examples
#' r <- readRDS(system.file("extdata", "example-rates.rds",
#'   package = "searchlight"
#' ))
#' r <- r[r$ethnicity %in% c("White", "Black"), ]
#' sl_count_model(r, n ~ ethnicity)
#' # Supply matching boundaries to request the residual Moran diagnostic.
sl_count_model <- function(counts, formula, family = c("poisson", "negbin"),
                           offset = "population", random = NULL,
                           boundaries = NULL, conf_level = 0.95) {
  family <- match.arg(family)
  contract <- sl_contract(counts)
  sl_validate_pair("White", "Black", conf_level)
  valid <- inherits(formula, "formula") && length(formula) == 3L &&
    identical(formula[[2]], as.name("n")) &&
    !grepl("offset\\s*\\(", paste(deparse(formula), collapse = ""))
  if (!valid) sl_abort("Use n as response and specify exposure via offset.")
  if (!is.null(random)) {
    invalid <- !inherits(random, "formula") || length(random) != 2L ||
      !requireNamespace("lme4", quietly = TRUE)
    if (invalid) {
      sl_abort("Random effects require lme4 and a one-sided formula.")
    }
    formula <- stats::as.formula(paste(
      paste(deparse(formula), collapse = ""),
      "+", paste(deparse(random[[2]]), collapse = "")
    ), env = environment(formula))
  }
  sl_require_columns(counts, unique(c(all.vars(formula), offset)))
  d <- as.data.frame(counts)
  e <- d[[offset]]
  if (offset == "population" && "months_submitted" %in% names(d)) {
    e <- e * d$months_submitted / 12
  }
  valid_n <- is.na(d$n) | (is.finite(d$n) & d$n >= 0 & d$n == floor(d$n))
  if (!all(valid_n)) sl_abort("Model counts must be nonnegative integers.")
  keep <- is.finite(e) & e > 0 & !is.na(d$n) &
    stats::complete.cases(d[all.vars(formula)])
  if ("ethnicity" %in% names(d)) keep <- keep & d$ethnicity != "Unknown"
  excluded <- list(rows = sum(!keep), events = sum(d$n[!keep], na.rm = TRUE))
  d$.sl_log_exposure <- log(ifelse(e > 0, e, NA_real_))
  d <- droplevels(d[keep, , drop = FALSE])
  if (!nrow(d)) sl_abort("No usable event-exposure cells.", "model")
  formula <- stats::update.formula(formula, . ~ . + offset(.sl_log_exposure))
  fit <- if (!is.null(random)) {
    if (family == "negbin") {
      lme4::glmer.nb(formula, data = d)
    } else {
      lme4::glmer(formula, data = d, family = stats::poisson())
    }
  } else if (family == "negbin") {
    MASS::glm.nb(formula, data = d)
  } else {
    stats::glm(formula, data = d, family = stats::poisson())
  }
  coefficients <- stats::coef(summary(fit))
  z <- stats::qnorm(1 - (1 - conf_level) / 2)
  estimate <- unname(coefficients[, 1])
  std_error <- unname(coefficients[, 2])
  result <- tibble::tibble(
    term = rownames(coefficients),
    estimate = estimate, std_error = std_error,
    statistic = unname(coefficients[, 3]), p_value = unname(coefficients[, 4]),
    exp_estimate = exp(estimate),
    conf_low = exp(estimate - z * std_error),
    conf_high = exp(estimate + z * std_error)
  )
  residual <- stats::residuals(fit, type = "pearson")
  df <- stats::df.residual(fit)
  diagnostics <- list(
    dispersion = if (df > 0) sum(residual^2) / df else NA_real_,
    residual_df = df, moran = sl_residual_moran(d, residual, boundaries),
    converged = if (is.null(random)) {
      isTRUE(fit$converged)
    } else {
      is.null(fit@optinfo$conv$lme4$messages)
    }
  )
  if (!diagnostics$converged) sl_warn("Count model did not converge.", "model")
  result <- sl_carry(result, contract, "sl_count_model")
  attr(result, "model") <- fit
  attr(result, "diagnostics") <- diagnostics
  attr(result, "excluded") <- excluded
  result
}

#' @noRd
sl_residual_moran <- function(data, residual, boundaries) {
  if (is.null(boundaries) || !"geography_code" %in% names(data)) {
    return(list(status = "not evaluated: supply area boundaries"))
  }
  sl_require_columns(boundaries, "geography_code")
  means <- tapply(residual, data$geography_code, mean)
  b <- boundaries[match(names(means), boundaries$geography_code), ]
  if (anyNA(b$geography_code)) sl_abort("Residual areas lack boundaries.")
  if (length(means) < 3 || stats::var(means) == 0) {
    return(list(status = "not estimable: too few areas or constant residuals"))
  }
  neighbours <- spdep::poly2nb(sf::st_transform(b, 27700), queen = FALSE)
  if (!sum(spdep::card(neighbours))) {
    return(list(status = "no adjacent areas"))
  }
  weights <- spdep::nb2listw(neighbours, style = "W", zero.policy = TRUE)
  diagnostic <- sl_with_seed(1, spdep::moran.mc(as.numeric(means), weights,
    nsim = 199, zero.policy = TRUE
  ))
  list(
    status = "exploratory permutation test of mean Pearson residuals",
    statistic = unname(diagnostic$statistic), p_value = diagnostic$p.value,
    areas = names(means)
  )
}
