# Developer-only release checks. URL checking is the only online operation.
dir.create("data-raw/work", recursive = TRUE, showWarnings = FALSE)
source("data-raw/runtime.R")
pkgload::load_all(quiet = TRUE)
roxygen2::roxygenise()
for (rd in list.files("man", pattern = "\\.Rd$", full.names = TRUE)) {
  writeLines(sub("[[:blank:]]+$", "", readLines(rd, warn = FALSE)), rd,
    useBytes = TRUE
  )
}
spelling_results <- spelling::spell_check_package()
saveRDS(spelling_results, "data-raw/work/spelling.rds")
capture.output(print(spelling_results), file = "data-raw/work/spelling.txt")
lint_results <- lintr::lint_package()
saveRDS(lint_results, "data-raw/work/lint.rds")
capture.output(print(lint_results), file = "data-raw/work/lint.txt")
stopifnot(nrow(spelling_results) == 0L, length(lint_results) == 0L)
url_results <- urlchecker::url_check()
saveRDS(url_results, "data-raw/work/urls.rds")
capture.output(print(as.data.frame(url_results)), file = "data-raw/work/urls.txt")
jsonlite::write_json(list(
  checked = as.character(Sys.time()),
  r_version = R.version.string,
  spelling_items = nrow(spelling_results), lint_items = length(lint_results),
  urls = as.data.frame(url_results)
), "inst/validation/M5-quality.json", pretty = TRUE, auto_unbox = TRUE)
