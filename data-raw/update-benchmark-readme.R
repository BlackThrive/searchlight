# Insert measured national timing evidence; refuse an unfinished benchmark.
metadata <- jsonlite::read_json(
  "inst/validation/benchmark-national-manifest.json"
)
stopifnot(
  isTRUE(metadata$complete),
  isTRUE(metadata$exact_assignment_and_count_agreement)
)
timings <- utils::read.csv("inst/validation/benchmark-national.csv")
totals <- timings[timings$stage == "total", ]
spatial <- timings[timings$stage == "spatial_assignment", ]
keys <- paste(totals$replicate, totals$method)
spatial_keys <- paste(spatial$replicate, spatial$method)
stopifnot(!anyDuplicated(keys), all(keys %in% spatial_keys))
labels <- c(
  one_national_batch = "One national batch",
  naive_monthly_batches = "Twelve monthly batches"
)
rows <- vapply(seq_len(nrow(totals)), function(i) {
  sprintf(
    "| %s | %s | %.1f | %.1f | %.1f |", totals$replicate[i],
    labels[totals$method[i]], totals$elapsed_seconds[i],
    spatial$elapsed_seconds[match(keys[i], spatial_keys)],
    totals$user_seconds[i] + totals$system_seconds[i]
  )
}, character(1))
section <- c(
  "<!-- BENCHMARK:START -->", "", "## Measured national benchmark", "",
  "The local 12-month build processed 476,738 events against 7,264 MSOAs.",
  "Both methods produced the same event assignments and aggregate counts.",
  "Elapsed and CPU times are measured seconds; CPU combines user and system time.",
  "",
  "| Run | Method | Total elapsed | Spatial elapsed | Total CPU |",
  "|---|---|---:|---:|---:|", rows, "",
  "The comparison includes ZIP/CSV verification, parsing, coverage audit, local",
  "spatial assignment and aggregation. Initial downloads, library loading and",
  "writing validation artifacts are excluded. The ZIP, extracted CSVs and ONS",
  "boundaries were already cached. OS caching and concurrent workstation load",
  "were uncontrolled; these timings are not a hardware-independent guarantee.",
  if (isTRUE(metadata$resumed_from_saved_national_run)) {
    "The monthly comparison resumed in a new R process against the saved national result."
  } else {
    character()
  },
  "The alternative repeats boundary preparation and assignment each month.",
  "Stage timings, environment and scope are retained in",
  "`inst/validation/benchmark-national.csv` and its manifest.",
  "", "<!-- BENCHMARK:END -->"
)
readme <- readLines("README.md", warn = FALSE)
start <- match("<!-- BENCHMARK:START -->", readme)
end <- match("<!-- BENCHMARK:END -->", readme)
if (is.na(start) && is.na(end)) {
  readme <- c(readme, "", section)
} else {
  stopifnot(!is.na(start), !is.na(end), start < end)
  before <- if (start > 1) readme[seq_len(start - 1)] else character()
  after <- if (end < length(readme)) readme[seq.int(end + 1, length(readme))] else character()
  readme <- c(before, section, after)
}
writeLines(readme, "README.md", useBytes = TRUE)
