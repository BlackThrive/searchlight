# Build outside a synchronised workspace to avoid transient asset-file locks.
source("data-raw/runtime.R")
destination <- normalizePath("data-raw/pkgdown",
  winslash = "/",
  mustWork = FALSE
)
staging <- tempfile("searchlight-site-")
dir.create(staging)
inputs <- c(
  "DESCRIPTION", "NAMESPACE", "LICENSE", "LICENSE.md", "README.md",
  "NEWS.md", "AGENTS.md", "RELEASE_CHECKLIST.md", "_pkgdown.yml",
  "R", "man", "inst", "vignettes"
)
stopifnot(all(file.copy(inputs, staging, recursive = TRUE)))
pkgload::load_all(staging, quiet = TRUE)
pkgdown::build_site(staging,
  override = list(destination = "site"),
  new_process = FALSE, preview = FALSE, install = FALSE
)
built <- file.path(staging, "site")
files <- list.files(built,
  recursive = TRUE, full.names = TRUE,
  all.files = TRUE, no.. = TRUE
)
targets <- file.path(destination, substring(files, nchar(built) + 2L))
for (directory in unique(dirname(targets))) {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
}
stopifnot(all(file.copy(files, targets, overwrite = TRUE)))
message("Local documentation site built and copied to ", destination)
