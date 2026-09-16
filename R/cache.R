#' Locate the searchlight cache
#'
#' Returns the cache path without creating it. Acquisition functions
#' explicitly
#' create and write to this directory. Set `options(searchlight.cache_dir
#' = ...)`
#' to override the platform default, or pass an explicit `dir`.
#' @return A character path.
#' @family ingest
#' @seealso [sl_archive_index()]
#' @export
#' @examples
#' sl_cache_dir()
sl_cache_dir <- function() {
  getOption("searchlight.cache_dir", tools::R_user_dir(
    "searchlight", "cache"
  ))
}

#' Clear a marked searchlight cache
#'
#' Only removes searchlight-managed entries in a directory bearing the marker
#' created by acquisition. Other user files are retained. This is destructive.
#' @param dir Cache directory.
#' @return Invisibly, paths removed.
#' @family ingest
#' @seealso [sl_cache_dir()]
#' @export
#' @examples
#' d <- tempfile()
#' dir.create(d)
#' file.create(file.path(d, ".searchlight-cache"))
#' sl_cache_clear(d)
#' unlink(d, recursive = TRUE)
sl_cache_clear <- function(dir = sl_cache_dir()) {
  if (!file.exists(file.path(dir, ".searchlight-cache"))) {
    sl_abort(
      "Refusing to clear a directory without a searchlight cache marker."
    )
  }
  entries <- list.files(dir, full.names = TRUE)
  owned <- grepl(
    paste0(
      "^([0-9]{4}-[0-9]{2}\\.zip|archive-index\\.rds|",
      "archive-manifest\\.rds|snapshots|snapshot-manifest\\.rds)$"
    ),
    basename(entries)
  )
  unlink(entries[owned], recursive = TRUE)
  invisible(entries[owned])
}

#' @noRd
sl_prepare_cache <- function(dir) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(dir)) {
    sl_abort(
      "Cannot create the requested cache directory."
    )
  }
  marker <- file.path(dir, ".searchlight-cache")
  if (!file.exists(marker)) file.create(marker)
  normalizePath(dir, winslash = "/", mustWork = TRUE)
}
