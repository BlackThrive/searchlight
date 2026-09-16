# Explicit offline validation; never sourced by package checks.
# Run from the package root after loading searchlight (or pkgload::load_all()).
replications <- as.integer(Sys.getenv("SEARCHLIGHT_REPLICATIONS", "20"))
stopifnot(is.finite(replications), replications >= 2)
conditions <- expand.grid(
  mechanism = c("mcar", "mar", "mnar"), missing_rate = c(0.1, 0.3, 0.6),
  stringsAsFactors = FALSE
)
rows <- list()
started <- Sys.time()
for (condition in seq_len(nrow(conditions))) {
  for (replicate in seq_len(replications)) {
    seed <- 9000 + 1000 * condition + replicate
    simulation <- sl_simulate(
      side = 5, seed = seed,
      missingness = conditions$mechanism[condition],
      missing_rate = conditions$missing_rate[condition]
    )
    complete <- sl_rate_ratio(sl_rates(
      simulation$complete_counts, simulation$population
    ))
    bounds <- sl_missing_ethnicity_bounds(
      simulation$counts, simulation$population
    )
    bounds$realised_complete_ratio <- complete$ratio[
      match(bounds$geography_code, complete$geography_code)
    ]
    bounds$generating_ratio <- simulation$truth$ratio[
      match(bounds$geography_code, simulation$truth$geography_code)
    ]
    bounds$contains_realised <- bounds$lower_bound <=
      bounds$realised_complete_ratio & bounds$upper_bound >=
      bounds$realised_complete_ratio
    bounds$contains_generating <- bounds$lower_bound <=
      bounds$generating_ratio & bounds$upper_bound >= bounds$generating_ratio
    bounds$width <- bounds$upper_bound - bounds$lower_bound
    bounds$mechanism <- conditions$mechanism[condition]
    bounds$missing_rate <- conditions$missing_rate[condition]
    bounds$replicate <- replicate
    bounds$seed <- seed
    stopifnot(all(bounds$contains_realised))
    rows[[length(rows) + 1L]] <- tibble::as_tibble(bounds)
  }
  message("Completed missingness condition ", condition, "/", nrow(conditions))
}
areas <- dplyr::bind_rows(rows)
# One extrema record per area, rather than counting it once per scenario.
unique_bounds <- areas[areas$scenario == "all_to_reference", ]
replicate_metrics <- dplyr::summarise(
  dplyr::group_by(
    unique_bounds,
    .data$mechanism, .data$missing_rate, .data$replicate
  ),
  realised_containment = mean(.data$contains_realised),
  generating_containment = mean(.data$contains_generating),
  median_width = stats::median(.data$width),
  infinite_width_share = mean(!is.finite(.data$width)), .groups = "drop"
)
summary <- dplyr::summarise(
  dplyr::group_by(
    replicate_metrics,
    .data$mechanism, .data$missing_rate
  ),
  replications = dplyr::n(),
  realised_containment = mean(.data$realised_containment),
  generating_containment = mean(.data$generating_containment),
  mean_median_width = mean(.data$median_width),
  mcse_median_width = stats::sd(.data$median_width) / sqrt(dplyr::n()),
  infinite_width_share = mean(.data$infinite_width_share), .groups = "drop"
)
scenario_summary <- dplyr::summarise(
  dplyr::group_by(
    areas,
    .data$mechanism, .data$missing_rate, .data$scenario
  ),
  bias_vs_complete_events = mean(.data$ratio - .data$realised_complete_ratio),
  rmse_vs_complete_events = sqrt(mean((.data$ratio -
    .data$realised_complete_ratio)^2)), .groups = "drop"
)
dir.create("inst/validation", recursive = TRUE, showWarnings = FALSE)
readr::write_csv(replicate_metrics, "inst/validation/missingness-replicates.csv")
readr::write_csv(summary, "inst/validation/missingness-summary.csv")
readr::write_csv(scenario_summary, "inst/validation/missingness-scenarios.csv")
# Compressed area-level evidence keeps installed package size bounded.
saveRDS(areas, "inst/validation/missingness-areas.rds", compress = "xz")
jsonlite::write_json(list(
  started = as.character(started), finished = as.character(Sys.time()),
  replications = replications, areas_per_replication = 25,
  conditions = conditions, area_scenario_rows = nrow(areas),
  seed_rule = "9000 + 1000*condition_index + replicate",
  all_realised_ratios_contained = all(areas$contains_realised),
  interpretation = paste(
    "Bounds identify reallocations of recorded events. Generating rate ratios",
    "also have Poisson sampling variation and need not be inside those bounds.",
    "Force/object MAR allocation additionally transports composition across areas."
  )
), "inst/validation/missingness-manifest.json", pretty = TRUE, auto_unbox = TRUE)
