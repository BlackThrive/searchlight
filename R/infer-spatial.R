#' Estimate a multivariate spatial stop-rate disparity surface
#'
#' Uses CARBayes MVS.CARleroux with two Poisson responses and a matrix of log
#' population-time offsets. Each ethnicity has its own spatial effect phi_ig.
#' The equivalent shared/contrast decomposition is u_i=(phi_ir+phi_ic)/2,
#' v_ir=(phi_ir-phi_ic)/2 and v_ic=-v_ir. These components have the covariance
#' induced by the multivariate prior; they are not separately independent
#'   priors.
#' The full posterior ratio is exp(alpha_c-alpha_r+phi_ic-phi_ir).
#' Smoothing stabilises under stated assumptions; it cannot repair exposure,
#' missing ethnicity, missing submissions or anonymised location errors.
#' @param counts Marginal event counts with a valid contract.
#' @param population Compatible marginal ethnicity exposure table.
#' @param boundaries sf polygons with geography_code.
#' @param reference,comparison Known self-defined ethnicity groups.
#' @param backend CARBayes. INLA is explicitly deferred beyond version 0.1.0.
#' @param burnin,n.sample,thin MCMC controls per chain, including burn-in
#'   in n.sample.
#' @param chains Number of independent chains, at least two, run on one core.
#' @param k Additional ratio threshold for exceedance probability.
#' @param adjacency Optional symmetric adjacency matrix named with
#'   geography codes.
#'   Otherwise rook adjacency is used; islands require an explicit decision.
#' @param boundary_threshold Warn if the assigned boundary-sensitive share
#'   exceeds
#'   this proportion (default 0.2).
#' @param seed Reproducible seed, restored on exit.
#' @param ... Prior and sampler arguments for MVS.CARleroux, such as rho
#'   or MALA.
#' @return An sl_spatial tibble with 90/95 percent intervals, exceedance
#'   probabilities, crude ratios, rank-normalised R-hat and bulk/tail ESS.
#'   Joint
#'   posterior draws, fitted model, diagnostics and boundaries are attributes.
#' @family inference
#' @seealso [sl_simulate()], [sl_spatial_map()], [sl_ranking_stability()]
#' @export
#' @examples
#' # A precomputed synthetic fit avoids MCMC in installed examples.
#' path <- system.file("extdata", "example-spatial.rds",
#'   package = "searchlight"
#' )
#' if (nzchar(path)) {
#'   fit <- readRDS(path)
#'   head(fit)
#'   head(sl_spatial_map(fit))
#' }
sl_spatial_disparity <- function(counts, population, boundaries,
                                 reference = "White", comparison = "Black",
                                 backend = c("carbayes", "inla"),
                                 burnin = 2000,
                                 n.sample = 12000, # nolint
                                 thin = 10,
                                 chains = 2, k = 2, adjacency = NULL,
                                 boundary_threshold = 0.2, seed = 1, ...) {
  backend <- match.arg(backend)
  if (backend != "carbayes") sl_abort("INLA is deferred beyond version 0.1.0.")
  sl_validate_pair(reference, comparison)
  settings <- c(burnin, n.sample, thin, chains)
  valid <- length(settings) == 4L && all(is.finite(settings)) &&
    all(settings == floor(settings)) && burnin >= 0 && thin >= 1 &&
    n.sample > burnin + 4 * thin && chains >= 2 &&
    length(k) == 1L && is.finite(k) && k > 0 &&
    length(boundary_threshold) == 1L && is.finite(boundary_threshold) &&
    boundary_threshold >= 0 && boundary_threshold <= 1
  if (!valid) sl_abort("Invalid MCMC controls or exceedance threshold.")
  contract <- sl_contract(counts)
  quality <- contract$assignment_quality
  if ("type" %in% names(quality)) {
    quality <- quality[quality$type == contract$analysis$geography, ]
  }
  checked <- is.data.frame(quality) &&
    "boundary_sensitive_share" %in% names(quality)
  sensitive <- checked &&
    any(quality$boundary_sensitive_share > boundary_threshold, na.rm = TRUE)
  if (sensitive) {
    sl_warn(
      "Boundary-sensitive locations exceed the declared threshold.",
      "geography"
    )
  }
  if (any(c("age_band", "sex") %in% names(population))) {
    sl_abort("Spatial disparity needs marginal ethnicity exposures.")
  }
  rates <- sl_rates(sl_collapse_counts(counts), population)
  crude <- sl_rate_ratio(rates, reference, comparison)
  selected <- !is.na(crude$geography_code) & crude$exposure_reference > 0 &
    crude$exposure_comparison > 0 & crude$excluded_pair_events == 0
  excluded <- crude[!selected, c(
    "geography_code", "unknown_events",
    "excluded_pair_events"
  )]
  crude <- crude[selected, ]
  areas <- sort(crude$geography_code)
  if (length(areas) < 3 || anyDuplicated(areas)) {
    sl_abort("Need at least three areas, each attributed to exactly one force.")
  }
  crude <- crude[match(areas, crude$geography_code), ]
  sl_require_columns(boundaries, "geography_code")
  if (!inherits(boundaries, "sf") || anyDuplicated(boundaries$geography_code)) {
    sl_abort("Supply unique sf boundaries.")
  }
  b <- boundaries[match(areas, boundaries$geography_code), ]
  if (anyNA(b$geography_code)) sl_abort("Model areas lack boundaries.")
  if (is.null(adjacency)) {
    nb <- spdep::poly2nb(sf::st_transform(b, 27700), queen = FALSE)
    if (any(spdep::card(nb) == 0)) {
      sl_abort("Isolated areas need an explicitly justified adjacency matrix.")
    }
    adjacency <- spdep::nb2mat(nb, style = "B")
  } else {
    invalid <- !is.matrix(adjacency) || is.null(rownames(adjacency)) ||
      is.null(colnames(adjacency)) || !all(areas %in% rownames(adjacency)) ||
      !all(areas %in% colnames(adjacency))
    if (invalid) {
      sl_abort("adjacency must be a matrix named by every model area.")
    }
    adjacency <- adjacency[areas, areas, drop = FALSE]
  }
  invalid <- any(!is.finite(adjacency)) || any(adjacency < 0) ||
    any(diag(adjacency) != 0) ||
    !isTRUE(all.equal(adjacency, t(adjacency), check.attributes = FALSE)) ||
    any(rowSums(adjacency) == 0)
  if (invalid) {
    sl_abort("adjacency must be symmetric with no isolated areas.")
  }
  dimnames(adjacency) <- list(areas, areas)
  response <- cbind(crude$n_reference, crude$n_comparison)
  exposure <- cbind(crude$exposure_reference, crude$exposure_comparison)
  if (any(colSums(response) == 0)) {
    sl_abort("Spatial fitting requires observed events in each group.", "model")
  }
  extra <- list(...)
  allowed <- c(
    "prior.mean.beta", "prior.var.beta", "prior.Sigma.df",
    "prior.Sigma.scale", "rho", "MALA"
  )
  invalid <- (is.null(names(extra)) && length(extra)) ||
    anyDuplicated(names(extra)) || any(!names(extra) %in% allowed)
  if (invalid) {
    sl_abort("Only documented prior and sampler arguments may be supplied.")
  }
  formula <- stats::as.formula("response ~ 1 + offset(log(exposure))")
  model_data <- data.frame(response = I(response), exposure = I(exposure))
  arguments <- c(list(
    formula = formula, data = model_data, family = "poisson", W = adjacency,
    burnin = burnin, n.sample = n.sample, thin = thin, n.chains = chains,
    n.cores = 1, verbose = FALSE
  ), extra)
  fit <- sl_with_seed(seed, do.call(CARBayes::MVS.CARleroux, arguments))
  # CARBayes samples are ordered by area, with group varying fastest.
  ref <- seq(1L, 2L * length(areas), by = 2L)
  cmp <- ref + 1L
  log_draws <- lapply(seq_len(chains), function(i) {
    beta <- as.matrix(fit$samples$beta[[i]])
    phi <- as.matrix(fit$samples$phi[[i]])
    sweep(
      phi[, cmp, drop = FALSE] - phi[, ref, drop = FALSE],
      1, beta[, 2] - beta[, 1], "+"
    )
  })
  draws <- exp(do.call(rbind, log_draws))
  colnames(draws) <- areas
  if (any(!is.finite(draws))) sl_abort("Nonfinite posterior ratios.", "model")
  intervals <- t(apply(draws, 2, stats::quantile,
    probs = c(0.025, 0.05, 0.5, 0.95, 0.975)
  ))
  diagnostic <- sl_chain_diagnostics(log_draws, areas)
  global <- sl_spatial_global_diagnostics(fit, is.null(extra$rho))
  result <- tibble::tibble(
    geography_code = areas,
    reference = reference, comparison = comparison,
    ratio = intervals[, 3], credible_low_90 = intervals[, 2],
    credible_high_90 = intervals[, 4], credible_low_95 = intervals[, 1],
    credible_high_95 = intervals[, 5],
    probability_above_1 = colMeans(draws > 1),
    probability_above_k = colMeans(draws > k), k = k,
    crude_ratio = crude$ratio, unknown_events = crude$unknown_events,
    rhat = diagnostic$rhat, ess_bulk = diagnostic$ess_bulk,
    ess_tail = diagnostic$ess_tail, converged = diagnostic$converged
  )
  if (any(!diagnostic$converged) || any(!global$converged)) {
    sl_warn(
      "MCMC diagnostics fail R-hat <= 1.01 or ESS >= 400; extend chains.",
      "convergence"
    )
  }
  contract$population <- sl_contract(population)$population
  result <- sl_carry(result, contract, "sl_spatial")
  attr(result, "posterior_draws") <- draws
  attr(result, "model") <- fit
  attr(result, "diagnostics") <- dplyr::bind_rows(diagnostic, global)
  attr(result, "boundaries") <- b
  attr(result, "excluded") <- excluded
  attr(result, "adjacency") <- adjacency
  attr(result, "mcmc_settings") <- list(
    burnin = burnin, n.sample = n.sample,
    thin = thin, chains = chains, seed = seed, prior_arguments = extra
  )
  result
}

#' @noRd
sl_chain_diagnostics <- function(chains, names) {
  rows <- lapply(seq_along(names), function(j) {
    x <- do.call(cbind, lapply(chains, function(chain) chain[, j]))
    rh <- posterior::rhat(x)
    bulk <- posterior::ess_bulk(x)
    tail <- posterior::ess_tail(x)
    tibble::tibble(
      parameter = names[j], rhat = rh, ess_bulk = bulk,
      ess_tail = tail, converged = is.finite(rh) && rh <= 1.01 &&
        is.finite(bulk) && bulk >= 400 && is.finite(tail) && tail >= 400
    )
  })
  dplyr::bind_rows(rows)
}

#' @noRd
sl_spatial_global_diagnostics <- function(fit, estimated_rho) {
  chains <- lapply(seq_along(fit$samples$beta), function(i) {
    sigma <- fit$samples$Sigma[[i]]
    x <- cbind(
      as.matrix(fit$samples$beta[[i]]), sigma[, 1, 1],
      sigma[, 1, 2], sigma[, 2, 2]
    )
    colnames(x) <- c(
      "alpha_reference", "alpha_comparison", "Sigma11",
      "Sigma12", "Sigma22"
    )
    if (estimated_rho) x <- cbind(x, rho = as.matrix(fit$samples$rho[[i]])[, 1])
    x
  })
  sl_chain_diagnostics(chains, colnames(chains[[1]]))
}

#' Join spatial posterior summaries to their polygons
#' @param x An sl_spatial fit.
#' @return An sf object with summaries and its ingestion contract.
#' @family inference
#' @seealso [sl_spatial_disparity()]
#' @export
#' @examples
#' path <- system.file("extdata", "example-spatial.rds",
#'   package = "searchlight"
#' )
#' if (nzchar(path)) head(sl_spatial_map(readRDS(path)))
sl_spatial_map <- function(x) {
  if (!inherits(x, "sl_spatial")) sl_abort("Supply an sl_spatial fit.")
  result <- dplyr::left_join(attr(x, "boundaries"), tibble::as_tibble(x),
    by = "geography_code"
  )
  sl_carry(result, x)
}

#' @export
plot.sl_spatial <- function(x, ...) {
  mapped <- sl_spatial_map(x)
  crude <- mapped
  crude$estimate <- crude$crude_ratio
  crude$method <- "Crude event ratio"
  mapped$estimate <- mapped$ratio
  mapped$method <- "Multivariate CAR posterior median"
  data <- rbind(crude, mapped)
  data$estimate[!is.finite(data$estimate)] <- NA_real_
  ggplot2::ggplot(data) +
    ggplot2::geom_sf(ggplot2::aes(fill = .data$estimate),
      linewidth = 0.1
    ) +
    ggplot2::facet_wrap(~method) +
    ggplot2::scale_fill_viridis_c(
      name = "Stop-rate ratio",
      na.value = "grey90"
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(
      caption =
        "Smoothing is conditional on model assumptions; inspect convergence."
    )
}
