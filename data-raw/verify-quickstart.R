# Execute the published quick start verbatim, using only bundled inputs.
pkgload::load_all(quiet = TRUE)
readme <- readLines("README.md", warn = FALSE)
start <- match("```r", readme) + 1L
end <- which(readme == "```" & seq_along(readme) > start)[1] - 1L
code <- readme[seq.int(start, end)]
stopifnot(length(code) == 15L)
local({
  grDevices::pdf(tempfile(fileext = ".pdf"))
  on.exit(grDevices::dev.off())
  eval(parse(text = code))
})
jsonlite::write_json(
  list(
    checked = as.character(Sys.time()),
    lines = length(code), passed = TRUE, offline = TRUE
  ),
  "inst/validation/M5-quickstart.json",
  pretty = TRUE, auto_unbox = TRUE
)
