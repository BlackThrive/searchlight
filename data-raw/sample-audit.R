# Explicit, live acquisition. Never sourced by check or examples.
pkgload::load_all(quiet = TRUE)
cache <- ".cache"
lookup <- sl_lookups(cache)
stopifnot(!is.null(lookup))
pfa <- lookup$lad_pfa
pfa <- pfa[pfa$PFA25NM %in% c("West Yorkshire", "Dyfed-Powys"), ]
hierarchy <- lookup$census_hierarchy
hierarchy <- hierarchy[hierarchy$LAD22CD %in% pfa$LAD25CD, ]
# All nine LAD codes in these two areas persist across the relevant vintages.
stopifnot(length(unique(pfa$LAD25CD)) == 9L)
stopifnot(setequal(pfa$LAD25CD, hierarchy$LAD22CD))
hierarchy$pfa <- pfa$PFA25CD[match(hierarchy$LAD22CD, pfa$LAD25CD)]
hierarchy$force_id <- ifelse(hierarchy$pfa == "E23000010",
  "west-yorkshire", "dyfed-powys"
)
saveRDS(hierarchy, "inst/extdata/sample-lookups.rds", compress = "xz")
boundaries <- list()
assignment_boundaries <- list()
population <- list()
for (type in c("lsoa21", "msoa21")) {
  codes <- sort(unique(hierarchy[[if (type == "lsoa21") {
    "LSOA21CD"
  } else {
    "MSOA21CD"
  }]]))
  message(type, ": ", length(codes), " areas")
  b <- sl_boundaries(type, dir = cache, codes = codes, lookups = FALSE)
  stopifnot(!is.null(b), setequal(codes, b$geography_code))
  assignment_boundaries[[type]] <- b
  meta <- attr(b, "geography_metadata")
  b <- b[c("geography_code", "geography_name")]
  b <- rmapshaper::ms_simplify(b, keep = 0.2, keep_shapes = TRUE)
  meta$sample_simplification <- "mapshaper keep=0.2; keep_shapes=TRUE"
  attr(b, "geography_metadata") <- meta
  boundaries[[type]] <- b
  population[[type]] <- sl_population(codes, dir = cache)
  stopifnot(!is.null(population[[type]]))
  saveRDS(boundaries, "inst/extdata/sample-boundaries.rds", compress = "xz")
  saveRDS(population, "inst/extdata/sample-population.rds", compress = "xz")
}
cross <- sl_population_crosstab(unique(hierarchy$MSOA21CD), dir = cache)
stopifnot(!is.null(cross))
saveRDS(cross, "inst/extdata/sample-crosstab.rds", compress = "xz")
national <- sl_population_crosstab("K04000001", dir = cache)
stopifnot(!is.null(national))
saveRDS(national, "inst/extdata/standard-population.rds", compress = "xz")
records <- sl_assign_geography(sl_sample(), assignment_boundaries)
records$pfa <- hierarchy$pfa[match(records$lsoa21, hierarchy$LSOA21CD)]
records$lad <- hierarchy$LAD22CD[match(records$lsoa21, hierarchy$LSOA21CD)]
contract <- sl_contract(records)
contract$geography$pfa <- list(
  type = "pfa", vintage = "2025-04",
  method = "LSOA21-LAD22 then unchanged sample LAD codes to PFA25",
  layer_id = "8f77bda25c124e43aca5f3b90494e405", retrieved = lookup$retrieved
)
contract$geography$lad <- list(
  type = "lad", vintage = "2022-12",
  method = "ONS Census hierarchy lookup", retrieved = lookup$retrieved,
  layer_id = "b9ca90c10aaa4b8d9791e9859a38ca67"
)
records <- sl_carry(records, contract)
records <- sl_quality(records, population$msoa21)
saveRDS(records, "inst/extdata/sample-records.rds", compress = "xz")
readr::write_csv(
  sl_contract(records)$assignment_quality,
  "inst/validation/M2-assignment.csv"
)
readr::write_csv(sl_timestamp_quality(records), "inst/validation/M2-time.csv")
readr::write_csv(sl_benchmark(records), "inst/validation/M2-benchmark.csv")
ggplot2::ggsave("inst/validation/M2-coverage.png",
  plot(sl_coverage(records)),
  width = 7, height = 3, dpi = 120
)
print(sum(file.info(list.files("inst/extdata",
  recursive = TRUE,
  full.names = TRUE
))$size))
