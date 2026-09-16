# Build the reviewable source artifact after all local checks have completed.
source("data-raw/runtime.R")
source("data-raw/stage-package.R")
package_source <- stage_package_source(file.path(
  tempfile("searchlight-build-"),
  "searchlight"
))
artifact <- pkgbuild::build(package_source,
  dest_path = normalizePath("."), vignettes = TRUE,
  manual = FALSE, quiet = FALSE
)
jsonlite::write_json(list(
  built = as.character(Sys.time()), file = basename(artifact),
  sha256 = digest::digest(file = artifact, algo = "sha256"),
  bytes = file.info(artifact)$size,
  intended_version = "0.1.0",
  release_ready = FALSE,
  reason = "External release gates must be verified separately"
), "data-raw/work/source-artifact.json", pretty = TRUE, auto_unbox = TRUE)
