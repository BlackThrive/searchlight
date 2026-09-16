# Rebuild derived ethnicity only from the retained raw field; no acquisition.
Sys.setenv(NO_INTERNET_TEST = "true", VROOM_THREADS = "2")
pkgload::load_all(quiet = TRUE)
records <- sl_sample()
before <- records$ethnicity_5
mapped <- sl_map_ethnicity(records$self_defined_ethnicity_raw)
records$ethnicity_5 <- mapped$ethnicity_5
records$ethnicity_19 <- mapped$ethnicity_19
contract <- sl_contract(records)
contract$classification$mapping_version <-
  "PACE-2023/archive-labels-2026-09-16"
records <- sl_carry(records, contract)
stopifnot(
  sum(records$ethnicity_5 == "Black") == 58L,
  sum(records$ethnicity_5 == "Unknown") == 2280L
)
audit <- dplyr::count(tibble::tibble(
  raw = records$self_defined_ethnicity_raw,
  ethnicity_19 = records$ethnicity_19, ethnicity_5 = records$ethnicity_5
), .data$raw, .data$ethnicity_19, .data$ethnicity_5)
readr::write_csv(audit, "inst/validation/M4-classification-audit.csv")
message("Corrected ", sum(before != records$ethnicity_5), " classifications.")
saveRDS(records, "inst/extdata/sample-records.rds", compress = "xz")
source("data-raw/sample-rates.R")
