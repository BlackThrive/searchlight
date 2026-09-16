# Explicit offline vignette computation. Generated Rmd files contain no live R.
Sys.setenv(NO_INTERNET_TEST = "true", VROOM_THREADS = "2")
source("data-raw/runtime.R")
pkgload::load_all(quiet = TRUE)
originals <- list.files("vignettes", pattern = "\\.Rmd\\.orig$", full.names = TRUE)
for (original in originals) {
  input <- basename(original)
  output <- sub("\\.orig$", "", input)
  withr::with_dir("vignettes", {
    knitr::knit(input, output, quiet = TRUE)
  })
  path <- file.path("vignettes", output)
  lines <- readLines(path, warn = FALSE)
  lines <- sub("^(#>|#&gt;)[ \\t]+$", "\\1", lines)
  writeLines(lines, path, useBytes = TRUE)
  rmarkdown::render(file.path("vignettes", output),
    quiet = TRUE,
    output_dir = normalizePath("inst/validation"),
    output_file = sub("\\.Rmd$", ".html", output)
  )
  html <- file.path("inst/validation", sub("\\.Rmd$", ".html", output))
  writeLines(sub("[ \\t]+$", "", readLines(html, warn = FALSE)), html,
    useBytes = TRUE
  )
}
