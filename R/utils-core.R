#' @noRd
sl_abort <- function(message, subclass = "input") {
  rlang::abort(message, class = paste0("searchlight_error_", subclass))
}

#' @noRd
sl_warn <- function(message, subclass = "input") {
  rlang::warn(message, class = paste0("searchlight_warning_", subclass))
}

#' @noRd
sl_table <- function(name) {
  tibble::as_tibble(utils::read.csv(
    system.file("extdata", name, package = "searchlight"),
    colClasses = "character", na.strings = c("", "NA"),
    check.names = FALSE, strip.white = TRUE, fileEncoding = "UTF-8"
  ))
}

#' @noRd
sl_hash <- function(path, algo = "sha256") {
  digest::digest(file = path, algo = algo)
}

#' @noRd
sl_months <- function(x) {
  valid <- is.character(x) && length(x) > 0L && !anyNA(x)
  if (!valid || any(!grepl("^[0-9]{4}-(0[1-9]|1[0-2])$", x))) {
    sl_abort("Supply months as nonmissing YYYY-MM strings.")
  }
  sort(unique(x))
}

#' @noRd
sl_get <- function(url, path = NULL) {
  if (identical(Sys.getenv("NO_INTERNET_TEST"), "true")) {
    cli::cli_inform("Network disabled; use cached data or bundled fixtures.")
    return(NULL)
  }
  tryCatch(
    {
      request <- httr2::request(url) |>
        httr2::req_user_agent("searchlight/0.1.0") |>
        httr2::req_timeout(if (is.null(path)) 60 else 1800)
      response <- httr2::req_perform(request, path = path)
      # In-memory HTTP adapters (including offline fixtures) do not write path.
      if (!is.null(path) && !file.exists(path) && is.raw(response$body)) {
        writeBin(httr2::resp_body_raw(response), path)
      }
      response
    },
    error = function(e) {
      cli::cli_inform(c(
        "Source unavailable: {url}",
        "i" = "{conditionMessage(e)}",
        "i" = "Use a cached snapshot or retry acquisition later."
      ))
      NULL
    }
  )
}

#' @noRd
sl_require_columns <- function(x, columns) {
  missing <- setdiff(columns, names(x))
  if (length(missing)) {
    sl_abort(paste("Missing columns:", paste(missing, collapse = ", ")))
  }
}
