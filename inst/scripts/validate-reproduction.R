# Verify independent reference against the actual parsed national archive.
records <- readRDS(".cache/national-parsed.rds")
force_codes <- utils::read.csv("inst/extdata/ppap-totals.csv")
records$pfa <- force_codes$pfa_code[match(records$force_id, force_codes$force_id)]
population <- sl_exposure(
  utils::read.csv(
    "inst/validation/reproduction-population.csv"
  ),
  geography = "pfa",
  source = "Independent NOMIS TS021 Census 2021; ONS LAD22 to PFA22 aggregation"
)
counts <- sl_counts(records)
reference_counts <- utils::read.csv("inst/validation/reproduction-counts.csv")
keys <- c("force_id", "geography_code", "month", "ethnicity")
joined <- dplyr::full_join(tibble::as_tibble(counts)[c(keys, "n")],
  reference_counts[c(keys, "n")],
  by = keys, suffix = c("_package", "_reference")
)
stopifnot(
  nrow(joined) == nrow(reference_counts),
  identical(is.na(joined$n_package), is.na(joined$n_reference)),
  all(joined$n_package == joined$n_reference, na.rm = TRUE)
)
actual <- suppressWarnings(sl_rate_ratio(sl_rates(counts, population)))
expected <- utils::read.csv("inst/validation/reproduction-expected.csv")
actual <- actual[match(expected$geography_code, actual$geography_code), ]
stopifnot(identical(is.na(actual$ratio), is.na(expected$ratio)))
stopifnot(isTRUE(all.equal(actual$ratio, expected$ratio, tolerance = 1e-12)))
readr::write_csv(
  tibble::as_tibble(actual)[setdiff(names(actual), "model")],
  "inst/validation/reproduction-actual.csv"
)
jsonlite::write_json(list(
  all_monthly_count_cells_exact = TRUE, cells = nrow(joined),
  max_absolute_ratio_difference = max(abs(actual$ratio - expected$ratio), na.rm = TRUE),
  ratio_tolerance = 1e-12, forces = nrow(expected),
  complete_year_forces = sum(tolower(expected$complete_year) == "true"),
  missing_years = sum(is.na(expected$ratio)),
  interpretation = "Independent Python reference agrees with parsed archive counts and package event-rate ratios."
), "inst/validation/reproduction-check.json", pretty = TRUE, auto_unbox = TRUE)
saveRDS(counts, ".cache/reproduction-package-counts.rds")
