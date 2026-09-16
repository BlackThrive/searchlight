# Explicit offline sample report; never run by package checks.
pkgload::load_all(quiet = TRUE)
records <- sl_sample()
counts <- readRDS("inst/extdata/example-counts.rds")
rates <- readRDS("inst/extdata/example-rates.rds")
population <- readRDS("inst/extdata/sample-population.rds")$msoa21
estimates <- list(
  "Four-MSOA event-rate ratios" = sl_rate_ratio(rates),
  "Missing-ethnicity allocation" = sl_missing_ethnicity_bounds(counts, population),
  "Count regression" = sl_count_model(rates, n ~ ethnicity),
  "Three separate outcomes" = sl_hit_rates(records)
)
sl_report(records, "inst/validation/sample-report.html", estimates,
  title = "West Yorkshire and Dyfed-Powys: May-July 2026",
  assumptions = "Resident Census 2021 exposure is held fixed over the submitted months.",
  limitations = c(
    "Rates, bounds and count regression cover four example MSOAs selected for many events.",
    "Outcome summaries use all 4,657 supplied events; these analyses have different scopes.",
    "All three requested Dyfed-Powys submissions are missing."
  ), overwrite = TRUE
)
