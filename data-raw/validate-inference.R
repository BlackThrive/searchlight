# Explicit offline validation, after the replicated simulation script completes.
Sys.setenv(NO_INTERNET_TEST = "true", VROOM_THREADS = "2", OMP_NUM_THREADS = "2")
source("data-raw/runtime.R")
pkgload::load_all(quiet = TRUE)
manifest <- jsonlite::read_json("inst/validation/simulation-manifest.json")
stopifnot(isTRUE(manifest$complete))
replicates <- readr::read_csv("inst/validation/simulation-replicates.csv",
  show_col_types = FALSE)
areas <- readr::read_csv("inst/validation/simulation-areas.csv", show_col_types = FALSE)
stopifnot(nrow(replicates) == 6L * manifest$replications_per_condition,
  nrow(areas) == 150L * manifest$replications_per_condition,
  !anyDuplicated(areas[c("condition", "replicate", "geography_code", "method")]),
  !anyNA(areas[c("truth", "estimate", "lower", "upper", "model_converged")]))
records <- sl_sample()
hits <- sl_hit_rates(records, by = "object_group")
readr::write_csv(hits, "inst/validation/M4-hit-rates.csv")
readr::write_csv(attr(hits, "coefficients"), "inst/validation/M4-outcome-models.csv")
darkness <- sl_veil_of_darkness(records)
readr::write_csv(darkness, "inst/validation/M4-darkness.csv")
readr::write_csv(attr(darkness, "steps"), "inst/validation/M4-darkness-steps.csv")
readr::write_csv(
  attr(darkness, "excluded_force_months"),
  "inst/validation/M4-darkness-gating.csv"
)
source("data-raw/precompute_vignettes.R")
