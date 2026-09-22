#' Write an offline report of audited records and analysis results
#'
#' Renders the installed Markdown/Rmd template to a self-contained HTML file.
#' No Pandoc, network, model fitting or external web assets are required.
#' Supplied estimates must retain the same source snapshots and ethnicity
#' classification as records. Their analysis scope and diagnostics are shown.
#' Coverage describes source files; filtering does not redefine coverage.
#' Sampling intervals and assumption ranges have separate labelled sections.
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
  unknown <- sum(is.na(records$ethnicity_5) | records$ethnicity_5 == "Unknown")
  coverage <- sl_coverage(records)
  sections <- vapply(seq_along(estimates), function(i) {
    sl_report_estimate(estimates[[i]], names(estimates)[i], max_rows)
  }, character(1))
  if (!length(sections)) {
    sections <- "No estimates supplied; this report audits records."
  }
  sources <- contract[c(
    "source", "snapshots", "geography", "population",
    "classification", "created"
  )]
  values <- list(
    title = paste0("<p>", sl_html_escape(title), "</p>"),
    summary = paste0(
      "<p><strong>", format(nrow(records), big.mark = ","),
      " recorded events</strong>; ", format(unknown, big.mark = ","),
      " have Unknown self-defined ethnicity. Generated ",
      format(Sys.time(), tz = "UTC", usetz = TRUE), ".</p>"
    ),
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
    "<style>", css, "</style></head><body><main>", body,
    "</main></body></html>"
  )
  writeLines(enc2utf8(html), file, useBytes = TRUE)
  result <- sl_carry(tibble::tibble(
    file = normalizePath(file, winslash = "/"), records = nrow(records)
  ), contract)
  cli::cli_inform("Report written to {.file {file}}.")
  invisible(result)
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
    paste0("<tr><td>", paste(values, collapse = "</td><td>"), "</td></tr>")
  }, character(1))
  note <- if (total > max_rows) {
    paste0(
      "<p>Showing ", max_rows, " of ", total,
      " rows. Full results remain in the supplied R object.</p>"
    )
  } else {
    ""
  }
  paste0(
    note, '<div class="table-scroll"><table><thead><tr><th scope="col">',
    paste(sl_html_escape(names(x)), collapse = '</th><th scope="col">'),
    "</th></tr></thead><tbody>", paste(rows, collapse = "\n"),
    "</tbody></table></div>"
  )
}

#' @noRd
sl_report_estimate <- function(x, name, max_rows) {
  table <- function(x) sl_report_table(x, max_rows)
  sections <- paste0("<h3>", sl_html_escape(name), "</h3>")
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
        paste0("<h4>", sl_html_escape(key), "</h4>"), table(item)
      )
    } else if (!is.null(item)) {
      sections <- c(
        sections, paste0("<h4>", sl_html_escape(key), "</h4><pre>"),
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
    "</pre></details>"
  )
  paste(sections, collapse = "\n\n")
}
