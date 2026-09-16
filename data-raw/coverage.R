# Explicit developer check, with all network calls disabled or mocked.
Sys.setenv(NO_INTERNET_TEST = "true")
coverage <- covr::package_coverage()
saveRDS(coverage, "data-raw/coverage.rds")
percentage <- covr::percent_coverage(coverage)
cat("Line coverage:", percentage, "percent\n")
print(covr::zero_coverage(coverage))
jsonlite::write_json(list(
  checked = as.character(Sys.time()),
  r_version = R.version.string,
  line_coverage_percent = percentage
), "inst/validation/M4-coverage.json", pretty = TRUE, auto_unbox = TRUE)
