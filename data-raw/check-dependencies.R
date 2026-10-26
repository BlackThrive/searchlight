# Developer/CI guard: no suncalc dependency, including through other packages.
# Does not install or remove packages and makes no network requests.
check_searchlight_dependencies <- function(
  description = "DESCRIPTION", database = utils::installed.packages(),
  repository_database = NULL, require_absent = FALSE
) {
  strong_fields <- c("Depends", "Imports", "LinkingTo")
  columns <- c("Package", strong_fields)
  database <- database[, columns, drop = FALSE]
  if (!is.null(repository_database)) {
    # Binary installations may omit LinkingTo-only header packages. Use the
    # supplied repository metadata for those; installed versions take priority.
    extra <- !repository_database[, "Package"] %in% database[, "Package"]
    database <- rbind(
      database, repository_database[extra, columns, drop = FALSE]
    )
  }
  fields <- c(strong_fields, "Suggests", "Enhances")
  metadata <- read.dcf(description, fields = fields)
  package_names <- function(values) {
    values <- values[!is.na(values)]
    entries <- trimws(unlist(strsplit(paste(values, collapse = ","), ",")))
    names <- trimws(sub("\\s*\\(.*\\)", "", entries))
    setdiff(names[nzchar(names)], "R")
  }
  if ("suncalc" %in% package_names(metadata[1, ])) {
    stop("DESCRIPTION must not depend on or suggest suncalc.")
  }
  direct <- package_names(metadata[1, strong_fields])
  closure <- sort(unique(c(direct, unlist(tools::package_dependencies(
    packages = direct, db = database, which = strong_fields, recursive = TRUE
  ), use.names = FALSE))))
  if ("suncalc" %in% closure) {
    stop("A strong dependency reintroduces suncalc.")
  }
  missing <- setdiff(closure, database[, "Package"])
  if (length(missing)) {
    stop(
      "Cannot audit missing dependency metadata: ",
      paste(missing, collapse = ", ")
    )
  }
  if (require_absent && requireNamespace("suncalc", quietly = TRUE)) {
    stop("This check must run with suncalc unavailable.")
  }
  message("Verified ", length(closure), " strong dependencies without suncalc.")
  invisible(list(direct = sort(direct), strong = closure))
}
