# Local check driver. Run explicitly from the repository root.
dir.create("data-raw/checks", recursive = TRUE, showWarnings = FALSE)
source("data-raw/runtime.R")
roxygen2::roxygenise()
for (rd in list.files("man", pattern = "\\.Rd$", full.names = TRUE)) {
  lines <- readLines(rd, warn = FALSE)
  writeLines(sub("[[:blank:]]+$", "", lines), rd, useBytes = TRUE)
}
check_workspace <- tempfile("searchlight-check-")
dir.create(check_workspace)
source("data-raw/stage-package.R")
check_source <- stage_package_source(file.path(check_workspace, "searchlight"))
result <- devtools::check(
  pkg = check_source,
  document = FALSE,
  check_dir = check_workspace,
  manual = TRUE,
  args = "--timings",
  error_on = "never",
  env_vars = c(
    NO_INTERNET_TEST = "true", NOT_CRAN = "false",
    `_R_CHECK_SYSTEM_CLOCK_` = "FALSE",
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
example_times <- utils::read.table(file.path(
  evidence,
  "searchlight-Ex.timings"
), header = TRUE, check.names = FALSE)
stopifnot(all(example_times$elapsed < 5))
installed <- file.path(check_output, "searchlight")
installed_bytes <- sum(file.info(list.files(installed,
  recursive = TRUE, full.names = TRUE
))$size)
extdata_bytes <- sum(file.info(list.files("inst/extdata",
  recursive = TRUE, full.names = TRUE
))$size)
stopifnot(installed_bytes < 5000000, extdata_bytes < 2000000)
