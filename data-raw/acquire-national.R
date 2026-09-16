# Explicit live acquisition for the release benchmark; never run during check.
Sys.setenv(VROOM_THREADS = "2", OMP_NUM_THREADS = "2")
cache <- ".cache"
months <- format(seq(as.Date("2025-08-01"), as.Date("2026-07-01"),
  by = "month"
), "%Y-%m")
forces <- jsonlite::fromJSON("inst/extdata/forces.json")$id
forces <- setdiff(forces, "northern-ireland")
if (!file.exists(file.path(cache, "2026-07.zip"))) {
  index <- searchlight::sl_archive_index(cache, refresh = TRUE)
  stopifnot(!is.null(index))
  index <- index[index$archive_file == "2026-07.zip", ]
  stopifnot(nrow(index) == 1L)
  searchlight::sl_archive_download(months, forces, cache, index = index)
}
message("Extracting the national 12-month archive snapshot")
timing <- system.time(versions <- searchlight::sl_archive_snapshot(
  cache,
  months = months, forces = forces
))
versions <- versions[versions$month %in% months & versions$force_id %in% forces, ]
saveRDS(versions, ".cache/national-versions.rds")
message("Acquiring MSOA 2021 boundaries for England and Wales")
boundaries <- searchlight::sl_boundaries("msoa21", dir = cache, lookups = FALSE)
stopifnot(!is.null(boundaries), nrow(boundaries) > 7000)
saveRDS(boundaries, ".cache/national-msoa.rds")
jsonlite::write_json(list(
  months = months, requested_forces = forces,
  files = nrow(versions), events = sum(versions$n_records),
  snapshot_seconds = unname(timing[1:3]),
  boundaries = nrow(boundaries), boundary_source =
    attr(boundaries, "geography_metadata"),
  note = "Network and initial snapshot preparation are outside cached benchmarks."
), "inst/validation/national-acquisition.json", pretty = TRUE, auto_unbox = TRUE)
