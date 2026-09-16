#' Audit submission coverage on a full force-month grid
#'
#' Counts come from the immutable selected files, including after filtering
#' records. A submitted zero-row CSV is zero; an absent CSV is NA. Refreshes
#' describe differing version counts. Partial suspicion takes precedence over
#' refreshes, and uses preceding calendar months (at most twelve), not twelve
#' observed files. A changelog issue does not create a nonexistent submission.
#' @param records Contract-bearing records.
#' @param forces Force IDs; default is the contract's requested forces.
#' @param months Months; default is the contract's requested months.
#' @param changelog Table with force_id, month, note and optional issue flag.
#'   Default uses the bundled, dated changelog extract.
#' @param partial_threshold Fraction of trailing median, default 0.2.
#' @return An sl_coverage tibble with contract; plot gives a coverage heatmap.
#' @family audit
#' @seealso [sl_quality()], [sl_coverage_compare()], [sl_benchmark()]
#' @export
#' @examples
#' audit <- sl_coverage(sl_sample())
#' plot(audit)
sl_coverage <- function(records, forces = NULL, months = NULL,
                        changelog = NULL, partial_threshold = 0.2) {
  contract <- sl_contract(records)
  if (is.null(forces)) forces <- unique(contract$requested$force_id)
  if (is.null(months)) months <- unique(contract$requested$month)
  months <- sl_months(months)
  invalid <- !length(forces) || anyNA(forces) ||
    length(partial_threshold) != 1L ||
    !is.finite(partial_threshold) || partial_threshold < 0 ||
    partial_threshold > 1
  if (invalid) {
    sl_abort("Invalid coverage grid or threshold.")
  }
  grid <- tidyr::expand_grid(force_id = sort(unique(forces)), month = months)
  versions <- contract$versions
  key <- paste(versions$force_id, versions$month)
  index <- match(paste(grid$force_id, grid$month), key)
  grid$n_records <- versions$n_records[index]
  grid$status <- ifelse(is.na(index), "missing", "submitted")
  refreshed <- vapply(versions$alternatives, function(x) {
    length(unique(x$n_records)) > 1L
  }, logical(1))
  grid$status[which(refreshed[index])] <- "refreshed"
  grid$trailing_median <- NA_real_
  for (i in seq_len(nrow(grid))) {
    month <- as.Date(paste0(grid$month[i], "-01"))
    previous <- format(
      seq(month, by = "-1 month", length.out = 13)[-1],
      "%Y-%m"
    )
    eligible <- versions$force_id == grid$force_id[i] &
      versions$month %in% previous
    counts <- versions$n_records[eligible]
    if (length(counts)) grid$trailing_median[i] <- stats::median(counts)
  }
  suspect <- grid$n_records < partial_threshold * grid$trailing_median
  grid$status[which(suspect)] <- "partial_suspected"
  if (is.null(changelog)) changelog <- sl_table("changelog.csv")
  sl_require_columns(changelog, c("force_id", "month", "note"))
  if (!"issue" %in% names(changelog)) changelog$issue <- TRUE
  grid$changelog_note <- NA_character_
  for (i in seq_len(nrow(grid))) {
    matched <- changelog$force_id == grid$force_id[i] &
      changelog$month == grid$month[i]
    ix <- which(matched)
    if (length(ix)) {
      notes <- unique(changelog$note[ix])
      grid$changelog_note[i] <- paste(notes, collapse = "; ")
      issue <- any(as.logical(changelog$issue[ix]), na.rm = TRUE)
      if (!is.na(index[i]) && issue) {
        grid$status[i] <- "partial_suspected"
      }
    }
  }
  contract$coverage <- grid
  sl_carry(grid, contract, "sl_coverage")
}

#' @export
plot.sl_coverage <- function(x, ...) {
  ggplot2::ggplot(x, ggplot2::aes(
    x = .data$month, y = .data$force_id,
    fill = .data$status
  )) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::scale_fill_manual(
      values = c(
        submitted = "#167D8D",
        refreshed = "#7265A5", missing = "#D8DBDF",
        partial_suspected = "#D67C25"
      ),
      drop = FALSE
    ) +
    ggplot2::labs(x = "Month", y = "Force", fill = "Submission") +
    ggplot2::theme_minimal()
}

#' Compare coverage patterns across two periods
#'
#' Periods are explicit month vectors sorted chronologically. Comparability
#' means equal length, matching submitted positions, at least one submitted
#' position, and no partial suspicion. Identical missing positions are listed
#' but allow comparison of the same observed subset. This tests coverage only,
#' not seasonality, reporting practice or population comparability.
#' @param coverage Output of sl_coverage.
#' @param period_a,period_b Month vectors for comparison.
#' @return A tibble with comparable, submitted positions, and a list of gaps.
#' @family audit
#' @seealso [sl_coverage()]
#' @export
#' @examples
#' sl_coverage_compare(sl_coverage(sl_sample()), "2026-05", "2026-06")
sl_coverage_compare <- function(coverage, period_a, period_b) {
  contract <- sl_contract(coverage)
  periods <- list(a = sl_months(period_a), b = sl_months(period_b))
  output <- lapply(unique(coverage$force_id), function(force) {
    detail <- lapply(names(periods), function(label) {
      months <- periods[[label]]
      x <- coverage[coverage$force_id == force, ]
      index <- match(months, x$month)
      status <- x$status[index]
      status[is.na(status)] <- "missing"
      tibble::tibble(
        period = label, month = months, position = seq_along(months),
        status = status, submitted = status %in% c("submitted", "refreshed")
      )
    })
    a <- detail[[1]]$submitted
    b <- detail[[2]]$submitted
    all <- dplyr::bind_rows(detail)
    tibble::tibble(
      force_id = force,
      comparable = identical(a, b) && any(a) &&
        !any(all$status == "partial_suspected"),
      submitted_a = list(which(a)), submitted_b = list(which(b)),
      breaking_months = list(all[!all$submitted, ])
    )
  })
  sl_carry(dplyr::bind_rows(output), contract)
}

#' Cross-check annual totals against the Home Office
#'
#' Years end on 31 March. Ratios are withheld unless twelve force-months are
#' submitted or refreshed and the current records contain every selected row.
#' The benchmark is not an equality guarantee: scope of powers, event versus
#' person/vehicle reporting, publication cut-offs and revisions can differ.
#' @param records Contract-bearing records.
#' @param ppap_table Table with force_id, year_end and published_total.
#'   Default is the bundled Home Office table SS_20, year ending March 2025.
#' @param tolerance Flag absolute proportional differences exceeding this value.
#' @return A tibble with observed/published counts, coverage, ratio and flags.
#' @family audit
#' @seealso [sl_coverage()]
#' @export
#' @examples
#' sl_benchmark(sl_sample())
sl_benchmark <- function(records, ppap_table = NULL, tolerance = 0.1) {
  contract <- sl_contract(records)
  if (is.null(ppap_table)) ppap_table <- sl_table("ppap-totals.csv")
  sl_require_columns(ppap_table, c("force_id", "year_end", "published_total"))
  if (length(tolerance) != 1L || !is.finite(tolerance) || tolerance < 0) {
    sl_abort("Invalid benchmark tolerance.")
  }
  table <- ppap_table[ppap_table$force_id %in% contract$requested$force_id, ]
  result <- lapply(seq_len(nrow(table)), function(i) {
    row <- table[i, ]
    end <- as.integer(row$year_end)
    start <- as.Date(sprintf("%d-04-01", end - 1L))
    months <- format(seq(start, by = "month", length.out = 12), "%Y-%m")
    included <- contract$coverage$force_id == row$force_id &
      contract$coverage$month %in% months
    coverage <- contract$coverage[included, ]
    selected <- records$force_id == row$force_id & records$month %in% months
    observed <- sum(selected)
    good <- coverage$status %in% c("submitted", "refreshed")
    complete <- nrow(coverage) == 12L && all(good) &&
      observed == sum(coverage$n_records)
    row$observed_total <- if (nrow(coverage) && any(good)) {
      observed
    } else {
      NA_integer_
    }
    row$submitted_months <- sum(good)
    row$complete <- complete
    total <- as.numeric(row$published_total)
    row$ratio <- if (complete && is.finite(total) && total > 0) {
      observed / total
    } else {
      NA_real_
    }
    row$beyond_tolerance <- abs(row$ratio - 1) > tolerance
    row$reason <- if (complete) {
      "scope and revisions may differ"
    } else {
      "incomplete year, suspect coverage or filtered records"
    }
    row
  })
  sl_carry(dplyr::bind_rows(result), contract)
}
