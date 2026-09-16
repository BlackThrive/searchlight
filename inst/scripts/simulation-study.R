# Run explicitly from the repository root; no network and one MCMC core.
# SEARCHLIGHT_REPLICATIONS increases the pilot count for scheduled CI.
# SEARCHLIGHT_RESUME=true explicitly resumes unchanged code and settings.
Sys.setenv(NO_INTERNET_TEST = "true", VROOM_THREADS = "2", OMP_NUM_THREADS = "2",
  OPENBLAS_NUM_THREADS = "2")
pkgload::load_all(quiet = TRUE)
replications <- as.integer(Sys.getenv("SEARCHLIGHT_REPLICATIONS", "6"))
stopifnot(is.finite(replications), replications >= 2)
output <- "inst/validation"
dir.create(output, recursive = TRUE, showWarnings = FALSE)
rows <- area_rows <- list()
diagnostic_rows <- attempt_rows <- list()
replicate_path <- file.path(output, "simulation-replicates.csv")
area_path <- file.path(output, "simulation-areas.csv")
resume <- identical(Sys.getenv("SEARCHLIGHT_RESUME", "false"), "true")
if (resume && file.exists(replicate_path) && file.exists(area_path)) {
  rows <- list(readr::read_csv(replicate_path, show_col_types = FALSE))
  area_rows <- list(readr::read_csv(area_path, show_col_types = FALSE))
  stopifnot(all(rows[[1]]$replicate <= replications))
  key <- function(x) paste(x$condition, x$replicate)
  candidates <- unique(key(rows[[1]]))
  complete <- vapply(candidates, function(case) {
    r <- rows[[1]][key(rows[[1]]) == case, ]
    a <- area_rows[[1]][key(area_rows[[1]]) == case, ]
    expected <- expand.grid(geography_code = sprintf("SIM%04d", 1:25),
      method = c("crude", "smoothed"))
    nrow(r) == 2L && setequal(r$method, c("crude", "smoothed")) &&
      nrow(a) == 50L && !anyDuplicated(a[c("geography_code", "method")]) &&
      setequal(paste(a$geography_code, a$method),
        paste(expected$geography_code, expected$method)) &&
      !anyNA(a[c("truth", "estimate", "lower", "upper", "model_converged")])
  }, logical(1))
  if (any(!complete)) message("Recomputing incomplete checkpoints: ",
    paste(candidates[!complete], collapse = ", "))
  valid <- candidates[complete]
  rows[[1]] <- rows[[1]][key(rows[[1]]) %in% valid, ]
  area_rows[[1]] <- area_rows[[1]][key(area_rows[[1]]) %in% valid, ]
}
diagnostic_path <- file.path(output, "simulation-diagnostics.csv")
attempt_path <- file.path(output, "simulation-attempts.csv")
if (resume && file.exists(diagnostic_path)) {
  diagnostic_rows <- list(readr::read_csv(diagnostic_path, show_col_types = FALSE))
}
if (resume && file.exists(attempt_path)) {
  attempt_rows <- list(readr::read_csv(attempt_path, show_col_types = FALSE))
}
done <- if (length(rows)) unique(paste(rows[[1]]$condition,
  rows[[1]]$replicate)) else character()
job_limit <- as.integer(Sys.getenv("SEARCHLIGHT_MAX_NEW_REPLICATIONS",
  as.character(3L * replications)))
stopifnot(is.finite(job_limit), job_limit >= 1)
new <- 0L
started <- Sys.time()
for (condition in c("smooth", "discontinuous", "small")) {
  for (replicate in seq_len(replications)) {
    if (paste(condition, replicate) %in% done || new >= job_limit) next
    seed <- 1200 + match(condition, c("smooth", "discontinuous", "small")) * 100 +
      replicate
    s <- sl_simulate(side = 5, surface = condition, seed = seed)
    stopifnot(abs(cor(s$truth$ratio, s$truth$annual_intensity)) < 1e-10)
    messages <- character()
    run <- function(burn, total, thin) {
      message(condition, " replicate ", replicate, ": starting ", total,
        " iterations per chain")
      attempt_time <- system.time(value <- withCallingHandlers(
        sl_spatial_disparity(s$counts, s$population,
        s$boundaries, burnin = burn, n.sample = total, thin = thin, seed = seed + 50),
        searchlight_warning_convergence = function(w) {
          messages <<- c(messages, conditionMessage(w))
          invokeRestart("muffleWarning")
        }))[["elapsed"]]
      diagnostics <- attr(value, "diagnostics")
      diagnostics$condition <- condition
      diagnostics$replicate <- replicate
      diagnostics$iterations <- total
      diagnostic_rows[[length(diagnostic_rows) + 1L]] <<- diagnostics
      attempt_rows[[length(attempt_rows) + 1L]] <<- tibble::tibble(
        condition = condition, replicate = replicate, seed = seed,
        iterations = total, converged = all(diagnostics$converged),
        seconds = attempt_time)
      readr::write_csv(dplyr::bind_rows(diagnostic_rows), diagnostic_path)
      readr::write_csv(dplyr::bind_rows(attempt_rows), attempt_path)
      value
    }
    elapsed <- system.time({
      fit <- run(2000, 12000, 10)
      if (!all(attr(fit, "diagnostics")$converged)) fit <- run(6000, 40000, 10)
      if (!all(attr(fit, "diagnostics")$converged)) fit <- run(10000, 80000, 20)
    })[["elapsed"]]
    converged <- all(attr(fit, "diagnostics")$converged)
    crude <- sl_rate_ratio(sl_rates(s$counts, s$population))
    crude <- crude[match(fit$geography_code, crude$geography_code), ]
    truth <- s$truth$ratio[match(fit$geography_code, s$truth$geography_code)]
    for (method in c("crude", "smoothed")) {
      estimate <- if (method == "crude") crude$ratio else fit$ratio
      lower <- if (method == "crude") crude$conf_low else fit$credible_low_95
      upper <- if (method == "crude") crude$conf_high else fit$credible_high_95
      rows[[length(rows) + 1L]] <- tibble::tibble(condition = condition,
        replicate = replicate, seed = seed, method = method,
        rmse = sqrt(mean((estimate - truth)^2)),
        coverage = mean(lower <= truth & upper >= truth),
        rank_recovery = cor(estimate, truth, method = "spearman"),
        converged = if (method == "crude") TRUE else converged,
        model_iterations = attr(fit, "mcmc_settings")$n.sample,
        fitting_seconds = elapsed)
      area_rows[[length(area_rows) + 1L]] <- tibble::tibble(condition = condition,
        replicate = replicate, geography_code = fit$geography_code,
        method = method, truth = truth, estimate = estimate,
        lower = lower, upper = upper, model_converged = converged)
    }
    if (condition == "smooth" && replicate == 1) {
      # Keep a compact, deterministic subset of joint draws for offline examples.
      attr(fit, "model") <- NULL
      draws <- attr(fit, "posterior_draws")
      take <- unique(round(seq(1, nrow(draws), length.out = min(1000, nrow(draws)))))
      attr(fit, "posterior_draws") <- draws[take, , drop = FALSE]
      attr(fit, "bundled_draws") <- "1000 evenly spaced joint draws; diagnostics use full chains"
      attr(fit, "truth") <- s$truth
      saveRDS(fit, "inst/extdata/example-spatial.rds", compress = "xz")
    }
    message(condition, " replicate ", replicate, "/", replications,
      ": converged=", converged, "; seconds=", round(elapsed, 1))
    new <- new + 1L
    readr::write_csv(dplyr::bind_rows(rows), file.path(output, "simulation-replicates.csv"))
    readr::write_csv(dplyr::bind_rows(area_rows), file.path(output, "simulation-areas.csv"))
  }
}
results <- dplyr::bind_rows(rows)
summary <- dplyr::summarise(dplyr::group_by(results, .data$condition, .data$method),
  replications = dplyr::n(), mean_rmse = mean(.data$rmse),
  mean_coverage = mean(.data$coverage), mean_rank_recovery = mean(.data$rank_recovery),
  mcse_rmse = stats::sd(.data$rmse) / sqrt(dplyr::n()),
  mcse_coverage = stats::sd(.data$coverage) / sqrt(dplyr::n()),
  converged_fits = sum(.data$converged), .groups = "drop")
readr::write_csv(summary, file.path(output, "simulation-summary.csv"))
jsonlite::write_json(list(started = as.character(started),
  finished = as.character(Sys.time()), seed_rule = "1200 + condition_index*100 + replicate",
  lattice_side = 5, replications_per_condition = replications,
  completed_replicates = nrow(results) / 2,
  complete = nrow(results) == 2 * 3 * replications &&
    nrow(dplyr::bind_rows(area_rows)) == 50 * 3 * replications,
  resumed = resume,
  inference = "Poisson MCAR; 2 chains, one core; extend on convergence failure",
  r_version = R.version.string, package_version = as.character(packageVersion("CARBayes")),
  interpretation = "Finite pilot study. Report Monte Carlo error and failed convergence; no universal guarantee."),
  file.path(output, "simulation-manifest.json"), pretty = TRUE, auto_unbox = TRUE)
print(summary)
