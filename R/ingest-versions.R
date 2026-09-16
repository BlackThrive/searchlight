#' List force-month archive versions
#' @param dir A snapshot cache or bundled sample directory.
#' @return A tibble with each force-month's archive, CSV hash and row count.
#' @family ingest
#' @seealso [sl_archive_snapshot()], [sl_select_version()]
#' @export
#' @examples
#' sl_list_versions(system.file("extdata", "sample", package = "searchlight"))
sl_list_versions <- function(dir = sl_cache_dir()) {
  path <- file.path(dir, "snapshot-manifest.rds")
  if (!file.exists(path)) {
    sl_abort(
      "No snapshot manifest; run sl_archive_snapshot()."
    )
  }
  result <- readRDS(path)
  sl_require_columns(result, c(
    "force_id", "month", "archive_file", "snapshot_month", "csv_path",
    "csv_sha256", "n_records", "archive_sha256", "downloaded_at", "url"
  ))
  tibble::as_tibble(result)
}

#' Select one complete version per force-month
#'
#' Never deduplicates event rows. Ties are resolved by snapshot month and
#' archive
#' name. `max_rows` chooses the newest version among equal row counts.
#' Differences
#' greater than 1% of the smallest count are reported (zero to positive
#' is infinite).
#' @param versions Output from [sl_list_versions()].
#' @param rule Version selection rule.
#' @param manual For the manual rule, a tibble with `force_id`, `month`,
#'   `archive_file`, containing exactly one choice per force-month.
#' @return Selected versions with list-column alternatives and a `differences`
#'   attribute. Each row carries the selection rule.
#' @family ingest
#' @seealso [sl_read_records()]
#' @export
#' @examples
#' d <- system.file("extdata", "sample", package = "searchlight")
#' v <- sl_list_versions(d)
#' sl_select_version(v)
sl_select_version <- function(versions,
                              rule = c(
                                "latest", "earliest",
                                "max_rows", "manual"
                              ),
                              manual = NULL) {
  rule <- match.arg(rule)
  sl_require_columns(versions, c(
    "force_id", "month", "archive_file", "snapshot_month", "n_records"
  ))
  if (!nrow(versions)) sl_abort("There are no versions to select.")
  key <- paste(versions$force_id, versions$month)
  if (anyDuplicated(paste(key, versions$archive_file))) {
    sl_abort("Duplicate force-month-archive identifiers in manifest.")
  }
  if (anyNA(versions$n_records) || any(versions$n_records < 0)) {
    sl_abort("Version counts must be nonnegative and known.")
  }
  if (rule == "manual") {
    sl_require_columns(manual, c("force_id", "month", "archive_file"))
    mk <- paste(manual$force_id, manual$month)
    if (anyDuplicated(mk) || !setequal(mk, key)) {
      sl_abort("Manual selection must cover each force-month exactly once.")
    }
  }
  differences <- list()
  selected <- lapply(split(seq_len(nrow(versions)), key), function(indices) {
    group <- versions[indices, ]
    if (rule == "manual") {
      choice <- manual$archive_file[mk == key[indices[1]]]
      index <- which(group$archive_file == choice)
      if (length(index) != 1L) {
        sl_abort(
          "Manual choice is not an available archive."
        )
      }
    } else {
      index <- switch(rule,
        latest = order(group$snapshot_month, group$archive_file,
          decreasing = TRUE
        )[1],
        earliest = order(group$snapshot_month, group$archive_file)[1],
        max_rows = order(group$n_records, group$snapshot_month,
          group$archive_file,
          decreasing = TRUE
        )[1]
      )
    }
    span <- range(group$n_records)
    difference <- if (span[1] == 0) {
      if (span[2] == 0) 0 else Inf
    } else {
      diff(span) / span[1]
    }
    if (difference > 0.01) {
      differences[[length(differences) + 1L]] <<- tibble::tibble(
        force_id = group$force_id[1], month = group$month[1],
        min_records = span[1], max_records = span[2],
        relative_difference = difference
      )
    }
    row <- group[index, ]
    row$alternatives <- list(tibble::as_tibble(group))
    row$selection_rule <- rule
    row
  })
  result <- dplyr::bind_rows(selected)
  attr(result, "differences") <- dplyr::bind_rows(differences)
  if (length(differences)) {
    cli::cli_inform("Archive row counts differ by more than 1%:")
    for (difference in differences) {
      cli::cli_inform(paste(
        difference$force_id, difference$month,
        difference$min_records, "to", difference$max_records, "records"
      ))
    }
  }
  result
}
