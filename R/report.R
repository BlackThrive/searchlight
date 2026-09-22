#' Write an offline report of audited records and analysis results
#'
#' Renders the installed Markdown/Rmd template to a self-contained HTML file.
#' No Pandoc, network, model fitting or external web assets are required.
#' Supplied estimates must retain the same source snapshots and ethnicity
#' classification as records. Their analysis scope and diagnostics are shown.
#' Coverage describes source files; filtering does not redefine coverage.
#' Sampling intervals and assumption ranges have separate labelled sections.
#' The report includes a summary, section navigation and expandable audit
#' details. Tables retain their original column names in header tooltips.
#' @param records Contract-bearing search records.
#' @param file Explicit HTML output path. Its parent directory must exist.
#' @param estimates Uniquely named list of contract-bearing result tables.
#' @param title Report title, treated as text.
#' @param assumptions,limitations Additional statements, treated as text.
#' @param max_rows Maximum displayed rows per table; truncation is labelled.
#' @param overwrite Whether to replace an existing output file.
#' @return Invisibly, a one-row tibble with the output path and record count,
#'   carrying the ingestion contract. Writes only the requested output file.
#' @family reporting
#' @seealso [sl_coverage()], [sl_rate_ratio()], [sl_missing_ethnicity_bounds()]
#' @export
#' @examples
#' rates <- readRDS(system.file("extdata", "example-rates.rds",
#'   package = "searchlight"
#' ))
#' path <- tempfile(fileext = ".html")
#' sl_report(sl_sample(), path, estimates = list(ratios = sl_rate_ratio(rates)))
#' file.exists(path)
sl_report <- function(records, file, estimates = list(),
                      title = "Stop and search: evidence and assumptions",
                      assumptions = character(), limitations = character(),
                      max_rows = 500, overwrite = FALSE) {
  contract <- sl_contract(records)
  sl_require_columns(records, c("force_id", "month", "ethnicity_5"))
  valid <- is.character(file) && length(file) == 1L && !is.na(file) &&
    nzchar(file) && dir.exists(dirname(file)) && !dir.exists(file) &&
    is.character(title) && length(title) == 1L && !is.na(title) &&
    is.character(assumptions) && !anyNA(assumptions) &&
    is.character(limitations) && !anyNA(limitations) &&
    length(max_rows) == 1L && is.finite(max_rows) && max_rows >= 1 &&
    max_rows == floor(max_rows) && is.logical(overwrite) &&
    length(overwrite) == 1L && !is.na(overwrite)
  if (!valid) {
    sl_abort("Invalid report path, text or display options.", "report")
  }
  if (file.exists(file) && !overwrite) {
    sl_abort("Report exists; use another path or overwrite = TRUE.", "report")
  }
  valid_names <- !is.null(names(estimates)) && !anyNA(names(estimates)) &&
    all(nzchar(names(estimates))) && !anyDuplicated(names(estimates))
  valid <- is.list(estimates) && (length(estimates) == 0L || valid_names)
  if (!valid) sl_abort("Supply uniquely named estimate tables.", "report")
  for (estimate in estimates) {
    if (!is.data.frame(estimate)) {
      sl_abort("Estimates must be tables.", "report")
    }
    other <- sl_contract(estimate)
    same <- identical(other$source, contract$source) &&
      identical(other$classification, contract$classification) &&
      setequal(other$snapshots$sha256, contract$snapshots$sha256)
    if (!same) sl_abort("Estimate source or classification differs.", "report")
  }
  table <- function(x) sl_report_table(x, max_rows)
  coverage <- sl_coverage(records)
  sections <- vapply(seq_along(estimates), function(i) {
    sl_report_estimate(estimates[[i]], names(estimates)[i], max_rows)
  }, character(1))
  if (!length(sections)) {
    sections <- "<p>No estimates supplied; this report audits records.</p>"
  }
  sources <- contract[c(
    "source", "snapshots", "geography", "population",
    "classification", "created"
  )]
  values <- list(
    title = paste0("<h1>", sl_html_escape(title), "</h1>"),
    metadata = paste0(
      '<p class="report-meta">Source period: ',
      sl_html_escape(paste(format(
        as.Date(paste0(range(coverage$month), "-01")), "%b %Y"
      ), collapse = " to ")),
      ' <span aria-hidden="true">/</span> Generated ',
      sl_html_escape(format(Sys.time(), "%d %b %Y, %H:%M UTC", tz = "UTC")),
      "</p>"
    ),
    overview = sl_report_overview(records, coverage),
    coverage_summary = table(coverage[c(
      "force_id", "month", "n_records", "status"
    )]),
    coverage = table(coverage),
    timestamps = table(contract$timestamps),
    geography = table(contract$assignment_quality),
    estimates = paste(sections, collapse = "\n\n"),
    assumptions = sl_report_list(assumptions),
    limitations = sl_report_list(limitations),
    sources = paste0("<pre>", sl_html_escape(jsonlite::toJSON(
      sources,
      pretty = TRUE, auto_unbox = TRUE, na = "null", null = "null"
    )), "</pre>")
  )
  asset <- function(x) system.file("templates", x, package = "searchlight")
  template <- readLines(asset("report.Rmd"), warn = FALSE)
  for (key in names(values)) {
    marker <- paste0("{{", key, "}}")
    template[template == marker] <- values[[key]]
  }
  body <- commonmark::markdown_html(paste(template, collapse = "\n"))
  css <- readLines(asset("report.css"), warn = FALSE)
  html <- c(
    '<!doctype html><html lang="en"><head><meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    paste0("<title>", sl_html_escape(title), "</title>"),
    "<style>", css, "</style></head><body>", body,
    "</body></html>"
  )
  writeLines(enc2utf8(html), file, useBytes = TRUE)
  result <- sl_carry(tibble::tibble(
    file = normalizePath(file, winslash = "/"), records = nrow(records)
  ), contract)
  cli::cli_inform("Report written to {.file {file}}.")
  invisible(result)
}

#' @noRd
sl_report_overview <- function(records, coverage) {
  n <- nrow(records)
  unknown <- sum(is.na(records$ethnicity_5) | records$ethnicity_5 == "Unknown")
  missing <- sum(coverage$status == "missing")
  present <- nrow(coverage) - missing
  flagged <- sum(coverage$status %in% c("partial_suspected", "refreshed"))
  number <- function(x) format(x, big.mark = ",", trim = TRUE)
  share <- if (n) sprintf("%.1f%%", 100 * unknown / n) else "Not available"
  card <- function(label, value, note) {
    paste0(
      '<div class="metric"><dt>', label, '</dt><dd class="metric-value">',
      value, '</dd><dd class="metric-note">', note, "</dd></div>"
    )
  }
  paste0(
    '<dl class="metrics">',
    card("Recorded events", number(n), "Records supplied to this report"),
    card("Unknown ethnicity", share, paste0(
      number(unknown), " events; self-defined ethnicity"
    )),
    card(
      "Source files present", paste0(present, " / ", nrow(coverage)),
      "Requested force-months; see coverage below"
    ),
    '</dl><div class="coverage-note"><strong>Coverage at a glance</strong>',
    "<p>", number(missing), " missing force-months; ", number(flagged),
    " flagged as revised or possibly partial. Missing submissions are ",
    "unavailable data, never zero searches. Coverage describes source files, ",
    "even when the supplied records have been filtered.</p></div>"
  )
}

#' @noRd
sl_report_label <- function(x) {
  labels <- c(
    force_id = "Force", n_records = "Recorded events", conf_low = "CI lower",
    conf_high = "CI upper", n_reference = "Reference events",
    n_comparison = "Comparison events", p_value = "p-value"
  )
  result <- gsub("_", " ", x, fixed = TRUE)
  result <- paste0(toupper(substr(result, 1, 1)), substring(result, 2))
  matched <- match(x, names(labels))
  result[!is.na(matched)] <- unname(labels[matched[!is.na(matched)]])
  result
}

#' @noRd
sl_html_escape <- function(x) {
  x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x <- gsub("'", "&#39;", x, fixed = TRUE)
  x <- gsub("\r", "&#13;", x, fixed = TRUE)
  gsub("\n", "&#10;", x, fixed = TRUE)
}

#' @noRd
sl_report_list <- function(x) {
  if (!length(x)) {
    return("<p>No additional statements supplied.</p>")
  }
  paste0(
    "<ul><li>", paste(sl_html_escape(x), collapse = "</li><li>"),
    "</li></ul>"
  )
}

#' @noRd
sl_report_table <- function(x, max_rows) {
  if (!is.data.frame(x) || !nrow(x)) {
    return("<p>No rows available.</p>")
  }
  total <- nrow(x)
  x <- x[setdiff(names(x), c("model", "models"))]
  x <- as.data.frame(x)[seq_len(min(total, max_rows)), , drop = FALSE]
  numeric <- vapply(x, is.numeric, logical(1))
  classes <- ifelse(numeric, ' class="numeric"', "")
  cells <- lapply(x, function(column) {
    if (is.list(column)) {
      column <- vapply(column, function(y) {
        as.character(jsonlite::toJSON(y, auto_unbox = TRUE, na = "null"))
      }, character(1))
    } else if (is.numeric(column)) {
      column <- trimws(formatC(column, digits = 5, format = "g"))
    } else {
      column <- as.character(column)
    }
    column[is.na(column)] <- "NA"
    sl_html_escape(column)
  })
  rows <- vapply(seq_len(nrow(x)), function(i) {
    values <- vapply(cells, `[`, character(1), i)
    if ("status" %in% names(values)) {
      status <- values["status"]
      if (status %in% c(
        "submitted", "missing", "refreshed", "partial_suspected"
      )) {
        values["status"] <- paste0(
          '<span class="status status-', status, '">',
          gsub("_", " ", status, fixed = TRUE), "</span>"
        )
      }
    }
    paste0("<tr>", paste0(
      "<td", classes, ">", values, "</td>",
      collapse = ""
    ), "</tr>")
  }, character(1))
  note <- if (total > max_rows) {
    paste0(
      '<p class="table-note">Showing ', max_rows, " of ", total,
      " rows. Full results remain in the supplied R object.</p>"
    )
  } else {
    ""
  }
  paste0(
    note, '<div class="table-scroll" role="region" tabindex="0" ',
    'aria-label="Data table; scroll horizontally for more columns">',
    "<table><thead><tr>",
    paste0(
      '<th scope="col"', classes, ' title="', sl_html_escape(names(x)),
      '">', sl_html_escape(sl_report_label(names(x))), "</th>",
      collapse = ""
    ),
    "</tr></thead><tbody>", paste(rows, collapse = "\n"),
    "</tbody></table></div>"
  )
}

#' @noRd
sl_report_estimate <- function(x, name, max_rows) {
  table <- function(x) {
    if (all(c("ratio", "geography_code") %in% names(x))) {
      first <- intersect(c(
        "geography_code", "reference", "comparison", "scenario", "ratio",
        "conf_low", "conf_high", "lower_bound", "upper_bound"
      ), names(x))
      x <- x[c(first, setdiff(names(x), first))]
    }
    sl_report_table(x, max_rows)
  }
  sections <- paste0(
    '<article class="estimate-card"><h3>', sl_html_escape(name), "</h3>"
  )
  if (inherits(x, "sl_sensitivity")) {
    sampling <- attr(x, "sampling")
    if (is.null(sampling)) {
      sampling <- x[setdiff(names(x), c("lower_bound", "upper_bound"))]
    }
    assumptions <- x[setdiff(names(x), c(
      "conf_low", "conf_high", "rank_low", "rank_high"
    ))]
    sections <- c(
      sections, "<h4>Sampling uncertainty</h4>",
      sl_report_list(attr(x, "sampling_description")), table(sampling),
      "<h4>Assumption range</h4>",
      sl_report_list(attr(x, "assumption_description"))
    )
    if (any(c("lower_bound", "upper_bound") %in% names(x))) {
      sections <- c(sections, table(assumptions))
    }
  } else {
    sections <- c(
      sections,
      "<h4>Estimates and sampling uncertainty</h4>", table(x)
    )
  }
  attributes <- c(
    "coefficients", "diagnostics", "excluded", "exclusions",
    "steps", "excluded_force_months"
  )
  for (key in attributes) {
    item <- attr(x, key, exact = TRUE)
    if (is.data.frame(item)) {
      sections <- c(
        sections,
        paste0("<h4>", sl_html_escape(sl_report_label(key)), "</h4>"),
        table(item)
      )
    } else if (!is.null(item)) {
      sections <- c(
        sections, paste0(
          "<h4>", sl_html_escape(sl_report_label(key)), "</h4><pre>"
        ),
        sl_html_escape(jsonlite::toJSON(item,
          pretty = TRUE,
          auto_unbox = TRUE, na = "null", null = "null"
        )), "</pre>"
      )
    }
  }
  ct <- sl_contract(x)
  details <- list(
    analysis = ct$analysis, scope = ct$scope,
    population = ct$population, assumptions = attr(x, "assumptions"),
    mcmc_settings = attr(x, "mcmc_settings")
  )
  sections <- c(
    sections,
    "<details><summary>Analysis scope and assumptions</summary><pre>",
    sl_html_escape(jsonlite::toJSON(details,
      pretty = TRUE,
      auto_unbox = TRUE, na = "null", null = "null"
    )),
    "</pre></details></article>"
  )
  paste(sections, collapse = "\n\n")
}
