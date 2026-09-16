# Windows R CMD build copies the tree before applying .Rbuildignore.
# Stage package inputs explicitly so archive caches are never copied.
stage_package_source <- function(destination) {
  inputs <- c(
    "DESCRIPTION", "NAMESPACE", "LICENSE", "LICENSE.md", "README.md",
    "NEWS.md", ".Rbuildignore", "R", "man", "inst", "tests", "vignettes",
    "data", "src", "exec", "demo", "tools", "po"
  )
  inputs <- inputs[file.exists(inputs)]
  dir.create(destination, recursive = TRUE, showWarnings = FALSE)
  stopifnot(all(file.copy(inputs, destination, recursive = TRUE)))
  normalizePath(destination, winslash = "/")
}
