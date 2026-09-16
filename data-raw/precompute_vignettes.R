# Explicit offline vignette computation. Generated Rmd files contain no live R.
Sys.setenv(NO_INTERNET_TEST = "true", VROOM_THREADS = "2")
source("data-raw/runtime.R")
pkgload::load_all(quiet = TRUE)
knitr::opts_chunk$set(error = FALSE)
originals <- list.files("vignettes", pattern = "\\.Rmd\\.orig$", full.names = TRUE)
selected <- Sys.getenv("SEARCHLIGHT_VIGNETTES", "")
if (nzchar(selected)) {
  chosen <- paste0(strsplit(selected, ",", fixed = TRUE)[[1]], ".Rmd.orig")
  originals <- originals[basename(originals) %in% chosen]
  stopifnot(length(originals) == length(chosen))
}
for (original in originals) {
  input <- basename(original)
  output <- sub("\\.orig$", "", input)
  withr::with_dir("vignettes", {
    knitr::knit(input, output, quiet = TRUE)
  })
  path <- file.path("vignettes", output)
  lines <- readLines(path, warn = FALSE)
  lines <- sub("[[:blank:]]+$", "", lines)
  writeLines(lines, path, useBytes = TRUE)
  rmarkdown::render(file.path("vignettes", output),
    quiet = TRUE,
    output_dir = normalizePath("inst/validation"),
    output_file = sub("\\.Rmd$", ".html", output)
  )
  html <- file.path("inst/validation", sub("\\.Rmd$", ".html", output))
  writeLines(sub("[[:blank:]]+$", "", readLines(html, warn = FALSE)), html,
    useBytes = TRUE
  )
}
