# Explicit offline document generation and local website verification.
Sys.setenv(NO_INTERNET_TEST = "true", VROOM_THREADS = "2")
source("data-raw/runtime.R")
roxygen2::roxygenise()
for (rd in list.files("man", pattern = "\\.Rd$", full.names = TRUE)) {
  writeLines(sub("[[:blank:]]+$", "", readLines(rd, warn = FALSE)), rd,
    useBytes = TRUE
  )
}
source("data-raw/update-benchmark-readme.R")
source("data-raw/render-report.R")
source("data-raw/precompute_vignettes.R")
source("data-raw/build-site.R")
