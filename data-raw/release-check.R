# Run after validation evidence and precomputed documentation are up to date.
source("data-raw/check.R")
file.copy(file.path(check_output, "00check.log"),
  "inst/validation/M5-check.log",
  overwrite = TRUE
)
file.copy(file.path(check_output, "tests", "testthat.Rout"),
  "inst/validation/M5-tests.txt",
  overwrite = TRUE
)
test_log <- "inst/validation/M5-tests.txt"
writeLines(sub("[[:blank:]]+$", "", readLines(test_log, warn = FALSE)),
  test_log,
  useBytes = TRUE
)
utils::write.table(example_times, "inst/validation/M5-example-timings.tsv",
  sep = "\t", quote = FALSE, col.names = NA
)
jsonlite::write_json(list(
  checked = as.character(Sys.time()), installed_bytes = installed_bytes,
  extdata_bytes = extdata_bytes,
  maximum_example_seconds = max(example_times$elapsed),
  check_errors = length(result$errors), check_warnings = length(result$warnings),
  check_notes = length(result$notes),
  local_environment = R.version.string,
  manual_pdf_checked = TRUE,
  exceptions = c(
    "offline incoming checks",
    "network system-clock probe disabled"
  )
), "inst/validation/M5-size.json", pretty = TRUE, auto_unbox = TRUE)
