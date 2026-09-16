# Local check driver. Run explicitly from the repository root.
dir.create("data-raw/checks", recursive = TRUE, showWarnings = FALSE)
roxygen2::roxygenise()
check_workspace <- tempfile("searchlight-check-")
dir.create(check_workspace)
result <- devtools::check(
  document = FALSE,
  check_dir = check_workspace,
  args = "--no-manual",
  error_on = "never",
  env_vars = c(
    NO_INTERNET_TEST = "true", `_R_CHECK_SYSTEM_CLOCK_` = "FALSE",
    VROOM_THREADS = "2", OMP_NUM_THREADS = "2", OPENBLAS_NUM_THREADS = "2"
  )
)
check_output <- file.path(check_workspace, "searchlight.Rcheck")
evidence <- "data-raw/checks/searchlight.Rcheck"
dir.create(evidence, recursive = TRUE, showWarnings = FALSE)
files <- list.files(check_output,
  pattern = "(\\.log|\\.out|\\.Rout|\\.timings)$", full.names = TRUE
)
file.copy(files, evidence, overwrite = TRUE)
saveRDS(result[c("errors", "warnings", "notes")], "data-raw/checks/result.rds")
stopifnot(
  length(result$errors) == 0L, length(result$warnings) == 0L,
  length(result$notes) == 0L
)
