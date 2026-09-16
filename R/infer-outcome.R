#' Describe three separate outcomes conditional on being searched
#'
#' Computes each requested outcome separately with Wilson binomial intervals.
#' Unknown ethnicity remains in descriptive tables and missing outcomes
#'   are not
#' failures. Logistic comparisons use known ethnicity, force and object fixed
#' effects; constant controls are explicitly omitted. These are associations
#' among searches. Differing hit rates alone do not establish discrimination;
#' selection, differing risk distributions and infra-marginality matter.
#' @param records Search records with the three derived binary outcome
#'   measures.
#' @param by Descriptive grouping columns; ethnicity_5 is always retained.
#' @param outcome Separate outcomes to calculate (all three by default).
#' @param reference,comparison Known self-defined ethnicity groups.
#' @param conf_level Wilson and logistic Wald confidence level.
#' @return An sl_hit_rates tibble. Models, coefficients and exclusions
#'   describe separate logistic models. The ingestion contract is retained.
#' @family inference
#' @seealso [sl_read_records()], [sl_veil_of_darkness()]
#' @export
#' @examples
#' hits <- sl_hit_rates(sl_sample())
#' head(hits)
#' attr(hits, "coefficients")
sl_hit_rates <- function(records, by = c("pfa", "object_group"),
                         outcome = c(
                           "any_action", "arrest",
                           "outcome_linked_to_object"
                         ),
                         reference = "White", comparison = "Black",
                         conf_level = 0.95) {
  contract <- sl_contract(records)
  sl_validate_pair(reference, comparison, conf_level)
  allowed <- c("any_action", "arrest", "outcome_linked_to_object")
  if (!length(outcome) || any(!outcome %in% allowed)) {
    sl_abort("Unknown outcome.")
  }
  by <- unique(c(by, "ethnicity_5"))
  sl_require_columns(records, c(by, outcome, "force_id", "object_group"))
  data <- tibble::as_tibble(records)
  data$ethnicity_5 <- as.character(data$ethnicity_5)
  data$ethnicity_5[is.na(data$ethnicity_5)] <- "Unknown"
  rows <- models <- coefficients <- exclusions <- list()
  z <- stats::qnorm(1 - (1 - conf_level) / 2)
  for (name in unique(outcome)) {
    value <- data[[name]]
    if (any(!is.na(value) & !value %in% c(0, 1))) {
      sl_abort("Outcome measures must be binary or missing.")
    }
    d <- data
    d$.outcome <- as.numeric(value)
    grouped <- dplyr::group_by(d, dplyr::across(dplyr::all_of(by)))
    table <- dplyr::summarise(grouped,
      searches = dplyr::n(),
      observed = sum(!is.na(.data$.outcome)),
      successes = sum(.data$.outcome, na.rm = TRUE),
      missing_outcome = sum(is.na(.data$.outcome)), .groups = "drop"
    )
    n <- table$observed
    p <- table$successes / n
    centre <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
    radius <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
    table$hit_rate <- ifelse(n > 0, p, NA_real_)
    table$conf_low <- ifelse(n > 0, pmax(0, centre - radius), NA_real_)
    table$conf_high <- ifelse(n > 0, pmin(1, centre + radius), NA_real_)
    table$outcome <- name
    rows[[name]] <- table
    pair <- d$ethnicity_5 %in% c(reference, comparison)
    keep <- pair & stats::complete.cases(d[c(
      "force_id", "object_group",
      ".outcome"
    )])
    exclusions[[name]] <- tibble::tibble(
      outcome = name, included = sum(keep),
      unknown_ethnicity = sum(d$ethnicity_5 == "Unknown"),
      other_ethnicity = sum(!pair & d$ethnicity_5 != "Unknown"),
      pair_missing_outcome_or_control = sum(pair & !keep)
    )
    d <- d[keep, ]
    d$.comparison <- as.integer(d$ethnicity_5 == comparison)
    controls <- c("force_id", "object_group")
    active <- controls[vapply(
      d[controls], function(x) length(unique(x)) > 1,
      logical(1)
    )]
    formula <- stats::reformulate(c(".comparison", active),
      response = ".outcome"
    )
    fit <- sl_logistic(d, formula, ".comparison", conf_level)
    fit$summary$outcome <- name
    fit$summary$omitted_constant_controls <- paste(setdiff(controls, active),
      collapse = ", "
    )
    coefficients[[name]] <- fit$summary
    models[name] <- list(fit$model)
  }
  result <- sl_carry(dplyr::bind_rows(rows), contract, "sl_hit_rates")
  attr(result, "models") <- models
  attr(result, "coefficients") <- dplyr::bind_rows(coefficients)
  attr(result, "exclusions") <- dplyr::bind_rows(exclusions)
  result
}

#' @noRd
sl_logistic <- function(data, formula, term, conf_level = 0.95) {
  variables <- all.vars(formula)
  response <- data[[variables[1]]]
  insufficient <- nrow(data) < 3 || length(unique(response)) < 2 ||
    length(unique(data[[term]])) < 2
  status <- if (insufficient) {
    "insufficient outcome/predictor variation"
  } else {
    "estimable"
  }
  fit <- NULL
  estimate <- low <- high <- se <- NA_real_
  messages <- character()
  if (status == "estimable") {
    fit <- withCallingHandlers(
      {
        stats::glm(formula, data = data, family = stats::binomial())
      },
      warning = function(w) {
        messages <<- c(messages, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    coefficient <- stats::coef(fit)[term]
    variance <- stats::vcov(fit)[term, term]
    stable <- fit$converged && is.finite(coefficient) && is.finite(variance) &&
      variance > 0 && !length(messages) && abs(coefficient) < 15
    if (stable) {
      se <- sqrt(variance)
      z <- stats::qnorm(1 - (1 - conf_level) / 2)
      estimate <- exp(coefficient)
      low <- exp(coefficient - z * se)
      high <- exp(coefficient + z * se)
    } else {
      status <- "unstable, aliased or separated fit; interval withheld"
    }
  }
  list(model = fit, summary = tibble::tibble(
    term = term,
    odds_ratio = unname(estimate), conf_low = unname(low),
    conf_high = unname(high), log_std_error = unname(se), n = nrow(data),
    status = status, model_warnings = paste(unique(messages), collapse = "; ")
  ))
}
