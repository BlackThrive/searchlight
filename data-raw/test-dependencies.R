# Regression checks for dependency auditing, including binary installations.
# Run after sourcing data-raw/check-dependencies.R; no network is used here.
local({
  fields <- c("Package", "Depends", "Imports", "LinkingTo")
  repository <- matrix(NA_character_,
    nrow = 3, ncol = 4,
    dimnames = list(c("bridge", "headers", "suncalc"), fields)
  )
  repository[, "Package"] <- rownames(repository)
  repository["bridge", "LinkingTo"] <- "headers"
  repository["headers", "Imports"] <- "suncalc"
  installed <- repository["bridge", , drop = FALSE]
  description <- tempfile()
  writeLines(c("Package: fixture", "Imports: bridge"), description)
  error_message <- function(...) {
    tryCatch(check_searchlight_dependencies(...), error = conditionMessage)
  }
  failure <- error_message(description, installed,
    repository_database = repository
  )
  stopifnot(is.character(failure), grepl("strong dependency", failure))
  repository["headers", "Imports"] <- NA_character_
  graph <- check_searchlight_dependencies(description, installed,
    repository_database = repository
  )
  stopifnot(identical(graph$strong, c("bridge", "headers")))
  # Installed versions take priority over different repository versions.
  repository["bridge", "Imports"] <- "suncalc"
  graph <- check_searchlight_dependencies(description, installed,
    repository_database = repository
  )
  stopifnot(identical(graph$strong, c("bridge", "headers")))
  failure <- error_message(description, installed)
  stopifnot(is.character(failure), grepl("missing dependency", failure))
  for (field in c("Imports", "Suggests")) {
    writeLines(c("Package: fixture", paste0(field, ": suncalc")), description)
    failure <- error_message(description, installed)
    stopifnot(is.character(failure), grepl("DESCRIPTION", failure))
  }
})
