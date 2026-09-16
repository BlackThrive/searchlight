#' @noRd
sl_query_url <- function(base, query) {
  request <- httr2::request(base)
  request <- do.call(httr2::req_url_query, c(list(request), query))
  request$url
}

#' @noRd
sl_json_get <- function(url) {
  response <- sl_get(url)
  if (is.null(response)) {
    return(NULL)
  }
  result <- tryCatch(httr2::resp_body_json(response), error = function(e) NULL)
  if (is.null(result) || !is.null(result$error)) {
    cli::cli_inform("Source returned no usable JSON: {url}")
    return(NULL)
  }
  result
}

#' @noRd
sl_arc_base <- function(service) {
  paste0(
    "https://services1.arcgis.com/ESMARspQHYMw9BZ9/",
    "arcgis/rest/services/", service, "/FeatureServer/0"
  )
}

#' @noRd
sl_arc_table <- function(service, fields, where = "1=1") {
  base <- paste0(sl_arc_base(service), "/query")
  rows <- list()
  offset <- 0L
  repeat {
    url <- sl_query_url(base, list(
      f = "json", where = where, outFields = paste(fields, collapse = ","),
      returnGeometry = "false", returnDistinctValues = "true",
      orderByFields = paste(fields, collapse = ","),
      resultOffset = offset, resultRecordCount = 1000
    ))
    result <- sl_json_get(url)
    if (is.null(result)) {
      return(NULL)
    }
    page <- dplyr::bind_rows(lapply(result$features, `[[`, "attributes"))
    if (!nrow(page)) break
    rows[[length(rows) + 1L]] <- page
    offset <- offset + nrow(page)
    if (!isTRUE(result$exceededTransferLimit) && nrow(page) < 1000L) break
    if (offset > 300000L) sl_abort("Unexpected lookup pagination.", "source")
  }
  unique(dplyr::bind_rows(rows))
}

#' @noRd
sl_codes_where <- function(field, codes) {
  if (is.null(codes)) {
    return("1=1")
  }
  invalid <- !length(codes) || anyNA(codes) ||
    any(!grepl("^[EW][0-9]{8}$", codes))
  if (invalid) {
    sl_abort("Expected ONS geography codes for England or Wales.")
  }
  paste0(field, " IN ('", paste(codes, collapse = "','"), "')")
}
