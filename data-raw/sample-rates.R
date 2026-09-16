# Offline aggregation universe from the verified, already bundled ONS lookup.
pkgload::load_all(quiet = TRUE)
lookup <- readRDS("inst/extdata/sample-lookups.rds")
units <- tibble::tibble(
  force_id = lookup$force_id, lsoa21 = lookup$LSOA21CD,
  msoa21 = lookup$MSOA21CD, lad = lookup$LAD22CD, pfa = lookup$pfa
)
records <- sl_sample()
ct <- sl_contract(records)
ct$units <- units
records <- sl_carry(records, ct)
saveRDS(records, "inst/extdata/sample-records.rds", compress = "xz")
# Small real-record analysis subset for fast reproducible examples and vignettes.
area <- names(sort(table(records$msoa21), decreasing = TRUE))[1:4]
counts <- sl_counts(records[records$msoa21 %in% area, ],
  by = c("msoa21", "ethnicity_5", "object_group"),
  units = units[units$msoa21 %in% area, ], forces = "west-yorkshire"
)
saveRDS(counts, "inst/extdata/example-counts.rds", compress = "xz")
pop <- readRDS("inst/extdata/sample-population.rds")$msoa21
rates <- sl_rates(sl_collapse_counts(counts), pop)
saveRDS(rates, "inst/extdata/example-rates.rds", compress = "xz")
cross <- readRDS("inst/extdata/sample-crosstab.rds")
demographic <- sl_counts(records[records$msoa21 %in% area, ],
  by = c("msoa21", "ethnicity_5", "age_band", "sex"),
  units = units[units$msoa21 %in% area, ], forces = "west-yorkshire"
)
saveRDS(demographic, "inst/extdata/example-demographic-counts.rds",
  compress = "xz"
)
readr::write_csv(
  sl_missing_ethnicity_bounds(counts, pop),
  "inst/validation/M3-sample-bounds.csv"
)
readr::write_csv(
  sl_standardise(demographic, cross),
  "inst/validation/M3-sample-standardised.csv"
)
