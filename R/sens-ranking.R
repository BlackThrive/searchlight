#' Assess area rank uncertainty under count models or posterior draws
#'
#' Bootstrap draws event counts from the fitted Poisson or negative-binomial
#' model, then ranks event-rate ratios (largest is rank 1). Quasi-Poisson does
#' not define a count distribution and is refused. Positive totals in both
#' groups are required for plug-in bootstrap; sparse zero-count areas need a
#' suitable posterior model. Ties receive random ranks under the saved seed.
#' Optional scenario rows are analysed separately, never pooled into a sampling
#' distribution. Pairwise stability means ordering probability above 0.95.
#' @param rate_ratios An sl_rate_ratio table, or a contract-bearing table with
#'   geography_code and a posterior_draws matrix attribute (draws by area).
#' @param method Parametric bootstrap or posterior ranks.
#' @param n Number of draws; default 1000.
#' @param seed Reproducible seed, restored on exit.
#' @return An sl_sensitivity tibble of median/95% rank intervals, with
#'   attributes
#'   rank_probabilities (matrix) and pairwise (ordering probabilities).
#' @family sensitivity
#' @seealso [sl_rate_ratio()], [sl_denominator_scenarios()]
#' @export
#' @examples
#' # Posterior draws can also be supplied by an independently fitted model.
#' x <- tibble::tibble(geography_code = c("a", "b"))
#' attr(x, "contract") <- sl_contract(sl_sample())
#' attr(x, "posterior_draws") <- cbind(a = c(1, 2, 3), b = c(3, 2, 1))
#' sl_ranking_stability(x, "posterior", n = 3)
sl_ranking_stability <- function(rate_ratios,
                                 method = c("bootstrap", "posterior"),
                                 n = 1000, seed = 1) {
  method <- match.arg(method)
  contract <- sl_contract(rate_ratios)
  if (length(n) != 1L || !is.finite(n) || n < 2 || n != as.integer(n)) {
    sl_abort("n must be an integer of at least two.")
  }
  multiple <- "scenario" %in% names(rate_ratios) &&
    length(unique(rate_ratios$scenario)) > 1L
  if (multiple) {
    scenarios <- split(rate_ratios, rate_ratios$scenario)
    posterior <- attr(rate_ratios, "posterior_draws")
    if (method == "posterior") {
      valid <- is.list(posterior) && all(names(scenarios) %in% names(posterior))
      if (!valid) sl_abort("Posterior scenarios need a named list of draws.")
    }
    pieces <- lapply(names(scenarios), function(name) {
      x <- scenarios[[name]]
      if (method == "posterior") attr(x, "posterior_draws") <- posterior[[name]]
      sl_ranking_stability(x, method, n, seed)
    })
    names(pieces) <- names(scenarios)
    result <- dplyr::bind_rows(lapply(names(pieces), function(scenario) {
      x <- tibble::as_tibble(pieces[[scenario]])
      x$scenario <- scenario
      x
    }))
    result <- sl_sensitivity(
      result, contract,
      "rank_low/rank_high are conditional on each scenario",
      "compare median ranks across the separately labelled scenarios"
    )
    attr(result, "rank_probabilities") <- lapply(
      pieces, attr,
      "rank_probabilities"
    )
    attr(result, "pairwise") <- lapply(pieces, attr, "pairwise")
    return(result)
  }
  sl_require_columns(rate_ratios, "geography_code")
  areas <- rate_ratios$geography_code
  if (anyNA(areas) || anyDuplicated(areas) || length(areas) < 2L) {
    sl_abort("Ranking requires at least two distinct, nonmissing areas.")
  }
  sl_with_seed(seed, {
    if (method == "posterior") {
      draws <- attr(rate_ratios, "posterior_draws")
      valid <- is.matrix(draws) && all(areas %in% colnames(draws)) &&
        nrow(draws) >= 2 && all(is.finite(draws)) && all(draws > 0)
      if (!valid) sl_abort("Supply a finite positive posterior_draws matrix.")
      draws <- draws[sample.int(nrow(draws), min(n, nrow(draws))), areas,
        drop = FALSE
      ]
    } else {
      required <- c(
        "n_reference", "n_comparison", "exposure_reference",
        "exposure_comparison", "method", "model"
      )
      sl_require_columns(rate_ratios, required)
      positive <- is.finite(rate_ratios$n_reference) &
        is.finite(rate_ratios$n_comparison) & rate_ratios$n_reference > 0 &
        rate_ratios$n_comparison > 0
      valid <- all(positive) &&
        all(rate_ratios$method %in% c("poisson", "negbin"))
      if (!valid) {
        sl_abort("Bootstrap needs positive groups and a count distribution.")
      }
      draws <- vapply(seq_along(areas), function(i) {
        row <- rate_ratios[i, ]
        fit <- row$model[[1]]
        if (is.null(fit)) sl_abort("Bootstrap requires fitted count models.")
        mean <- stats::fitted(fit)
        counts <- if (row$method == "negbin") {
          matrix(stats::rnbinom(
            n * length(mean),
            mu = rep(mean, each = n),
            size = fit$theta
          ), nrow = n)
        } else {
          matrix(stats::rpois(n * length(mean), rep(mean, each = n)),
            nrow = n
          )
        }
        group <- fit$model$group
        nr <- rowSums(counts[, group == row$reference, drop = FALSE])
        nc <- rowSums(counts[, group == row$comparison, drop = FALSE])
        (nc / row$exposure_comparison) / (nr / row$exposure_reference)
      }, numeric(n))
      colnames(draws) <- areas
      usable <- apply(draws, 1, function(x) !anyNA(x))
      if (any(!usable)) {
        sl_warn(
          "Some bootstrap draws have zero events in both groups; omitted.",
          "model"
        )
      }
      draws <- draws[usable, , drop = FALSE]
      if (nrow(draws) < 2L) sl_abort("Too few estimable bootstrap draws.")
    }
    ranks <- t(apply(draws, 1, function(x) rank(-x, ties.method = "random")))
    colnames(ranks) <- areas
    probability <- vapply(seq_along(areas), function(i) {
      tabulate(ranks[, i], nbins = length(areas)) / nrow(ranks)
    }, numeric(length(areas)))
    probability <- t(probability)
    dimnames(probability) <- list(areas, paste0("rank_", seq_along(areas)))
    pairs <- utils::combn(seq_along(areas), 2)
    pairwise <- tibble::tibble(
      area_a = areas[pairs[1, ]],
      area_b = areas[pairs[2, ]],
      probability_a_higher = vapply(seq_len(ncol(pairs)), function(j) {
        a <- draws[, pairs[1, j]]
        b <- draws[, pairs[2, j]]
        mean(a > b) + 0.5 * mean(a == b)
      }, numeric(1))
    )
    pairwise$stable <- pairwise$probability_a_higher >= 0.95 |
      pairwise$probability_a_higher <= 0.05
    result <- tibble::tibble(
      geography_code = areas,
      median_rank = unname(apply(ranks, 2, stats::median)),
      rank_low = unname(apply(ranks, 2, stats::quantile, 0.025, type = 1)),
      rank_high = unname(apply(ranks, 2, stats::quantile, 0.975, type = 1)),
      effective_draws = nrow(ranks), method = method
    )
    result <- sl_sensitivity(
      result, contract,
      "rank_low/rank_high describe conditional sampling or posterior ranks",
      "not evaluated for this single scenario"
    )
    attr(result, "rank_probabilities") <- probability
    attr(result, "pairwise") <- pairwise
    result
  })
}

#' @noRd
sl_with_seed <- function(seed, code) {
  if (length(seed) != 1L || !is.finite(seed)) sl_abort("Supply a finite seed.")
  withr::with_seed(seed, force(code))
}
