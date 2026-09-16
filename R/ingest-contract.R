#' Inspect an ingestion contract
#'
#' Contracts retain source provenance through subsetting and dplyr verbs. The
#' coverage and timestamp tables describe the ingested sources; `scope`
#' records
#' the currently visible row count and force-months after filtering. Filtering
#' does not turn a submitted file into a missing submission.
#' @param x Records, aggregates or a contract.
#' @return A named list of class `sl_contract`. `summary()` returns coverage.
#' @family ingest
#' @seealso [sl_read_records()], [sl_sample()]
#' @export
#' @examples
#' sl_contract(sl_sample())
sl_contract <- function(x) {
  result <- if (inherits(x, "sl_contract")) {
    x
  } else {
    attr(x,
      "contract",
      exact = TRUE
    )
  }
  if (!inherits(result, "sl_contract")) {
    sl_abort(
      "Object does not carry a searchlight ingestion contract.", "contract"
    )
  }
  required <- c(
    "source", "snapshots", "versions", "coverage", "geography",
    "assignment_quality", "timestamps", "population",
    "classification", "created"
  )
  if (!all(required %in% names(result))) {
    sl_abort("Incomplete ingestion contract.", "contract")
  }
  result
}

#' @noRd
sl_new_contract <- function() {
  structure(list(
    source = "data.police.uk archive",
    snapshots = tibble::tibble(), versions = tibble::tibble(),
    coverage = tibble::tibble(), geography = list(),
    assignment_quality = tibble::tibble(), timestamps = tibble::tibble(),
    population = list(),
    classification = list(
      scheme = "self-defined",
      mapping_version = "PACE-2023"
    ),
    created = list(
      timestamp = Sys.time(), package_version = "0.1.0",
      r_version = R.version.string
    )
  ), class = "sl_contract")
}

#' @noRd
sl_carry <- function(x, template, class = NULL) {
  contract <- sl_contract(template)
  if (is.data.frame(x) && all(c("force_id", "month") %in% names(x))) {
    contract$scope <- list(
      n_rows = nrow(x),
      force_months = unique(as.data.frame(x)[c("force_id", "month")])
    )
  }
  attr(x, "contract") <- contract
  if (!is.null(class)) class(x) <- unique(c(class, class(x)))
  x
}

#' @export
print.sl_contract <- function(x, ...) {
  cli::cli_h2("searchlight ingestion contract")
  cli::cli_text("Source: {x$source}")
  cli::cli_text(
    "Snapshots: {nrow(x$snapshots)}; selected versions: {nrow(x$versions)}"
  )
  cli::cli_text(
    "Ethnicity: {x$classification$scheme} ({x$classification$mapping_version})"
  )
  cli::cli_text("Audited force-months: {nrow(x$coverage)}")
  invisible(x)
}

#' @export
summary.sl_contract <- function(object, ...) {
  object$coverage
}

#' @export
`[.sl_records` <- function(x, i, j, ..., drop = FALSE) {
  result <- NextMethod("[")
  if (is.data.frame(result)) {
    result <- sl_carry(result, x, "sl_records")
  }
  result
}

#' @importFrom dplyr dplyr_reconstruct
#' @export
dplyr_reconstruct.sl_records <- function(data, template) {
  sl_carry(tibble::as_tibble(data), template, "sl_records")
}
