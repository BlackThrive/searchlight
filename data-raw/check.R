# Local check driver. Run explicitly from the repository root.
dir.create("data-raw/checks", recursive = TRUE, showWarnings = FALSE)
roxygen2::roxygenise()
result <- devtools::check(
  document = FALSE,
  check_dir = "data-raw/checks",
  args = "--no-manual",
  error_on = "never",
  env_vars = c(NO_INTERNET_TEST = "true", `_R_CHECK_SYSTEM_CLOCK_` = "FALSE")
)
saveRDS(result[c("errors", "warnings", "notes")], "data-raw/checks/result.rds")
stopifnot(
  length(result$errors) == 0L, length(result$warnings) == 0L,
  length(result$notes) == 0L
)
