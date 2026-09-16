# Run after national validation, documentation and styler::style_pkg().
options(readr.show_progress = FALSE, cli.progress_show_after = Inf)
stopifnot(!any(styler::style_pkg(dry = "on")$changed))
source("data-raw/release-quality.R")
source("data-raw/release-check.R")
Sys.setenv(NOT_CRAN = "true")
source("data-raw/coverage.R")
source("data-raw/external-release-check.R")
source("data-raw/release-build.R")
