# Run explicitly from the repository root with searchlight loaded.
# Requires data-raw/acquire-national.R inputs. All timed work is local/offline.
Sys.setenv(NO_INTERNET_TEST = "true", VROOM_THREADS = "2")
cache <- ".cache"
months <- format(seq(as.Date("2025-08-01"), as.Date("2026-07-01"),
  by = "month"
), "%Y-%m")
forces <- setdiff(
  jsonlite::fromJSON("inst/extdata/forces.json")$id,
  "northern-ireland"
)
boundaries <- readRDS(file.path(cache, "national-msoa.rds"))
replications <- as.integer(Sys.getenv("SEARCHLIGHT_BENCHMARK_REPLICATIONS", "1"))
stopifnot(replications >= 1, nrow(boundaries) == 7264L)
timings <- list()
reference_assignment <- reference_counts <- NULL
started <- Sys.time()
resuming <- identical(Sys.getenv("SEARCHLIGHT_BENCHMARK_RESUME"), "true")
if (resuming) {
  stopifnot(replications == 1L)
  previous <- readr::read_csv("inst/validation/benchmark-national.csv",
    show_col_types = FALSE)
  stopifnot(all(previous$method == "one_national_batch"),
    nrow(previous) == 5L)
  timings <- list(previous)
  saved <- readRDS(file.path(cache, "national-assigned.rds"))
  reference_assignment <- as.data.frame(saved)[c("msoa21",
    "msoa21_boundary_distance_m", "msoa21_boundary_sensitive",
    "msoa21_ambiguous")]
  reference_counts <- dplyr::count(tibble::as_tibble(saved),
    .data$force_id, .data$month, .data$msoa21, .data$ethnicity_5, name = "n")
  reference_counts <- dplyr::arrange(reference_counts,
    .data$force_id, .data$month, .data$msoa21, .data$ethnicity_5)
  rm(saved)
}
for (replicate in seq_len(replications)) {
  methods <- c("one_national_batch", "naive_monthly_batches")
  if (resuming) methods <- "naive_monthly_batches"
  if (replicate %% 2 == 0) methods <- rev(methods)
  for (method in methods) {
    message("Benchmark ", replicate, ": ", method)
    gc()
    total_start <- proc.time()
    step <- system.time({
      versions <- sl_archive_snapshot(cache, months = months, forces = forces)
      versions <- versions[versions$month %in% months &
        versions$force_id %in% forces, ]
      selected <- sl_select_version(versions)
    })
    snapshot_time <- unname(step[1:3])
    message("  Snapshot verified: ", nrow(selected), " files in ",
      snapshot_time[3], " seconds; parsing and auditing")
    step <- system.time({
      records <- sl_read_records(cache, selected)
      contract <- sl_contract(records)
      contract$requested <- tidyr::expand_grid(force_id = forces, month = months)
      attr(records, "contract") <- contract
      contract$coverage <- sl_coverage(records, forces = forces, months = months)
      attr(records, "contract") <- contract
    })
    parse_time <- unname(step[1:3])
    message("  Parsed: ", nrow(records), " events in ", parse_time[3],
      " seconds; assigning MSOAs")
    step <- system.time({
      if (method == "one_national_batch") {
        assigned <- sl_assign_geography(records, boundaries)
      } else {
        # A straightforward independent batch per calendar month repeats
        # boundary preparation and spatial-index construction twelve times.
        indices <- split(seq_len(nrow(records)), records$month)
        pieces <- lapply(indices, function(i) {
          sl_assign_geography(records[i, ], boundaries)
        })
        assigned <- dplyr::bind_rows(pieces)
        assigned <- assigned[order(unlist(indices, use.names = FALSE)), ]
        rm(pieces)
      }
    })
    assign_time <- unname(step[1:3])
    message("  Spatial assignment: ", assign_time[3], " seconds; aggregating")
    step <- system.time({
      counts <- dplyr::count(tibble::as_tibble(assigned),
        .data$force_id, .data$month, .data$msoa21, .data$ethnicity_5,
        name = "n"
      )
      counts <- dplyr::arrange(
        counts, .data$force_id, .data$month,
        .data$msoa21, .data$ethnicity_5
      )
    })
    aggregate_time <- unname(step[1:3])
    total_time <- unname((proc.time() - total_start)[1:3])
    message("  Total: ", total_time[3], " seconds; saving validation artifacts")
    assignment <- as.data.frame(assigned)[c(
      "msoa21",
      "msoa21_boundary_distance_m", "msoa21_boundary_sensitive",
      "msoa21_ambiguous"
    )]
    saveRDS(list(assignment = assignment, counts = counts,
      stage_times = list(snapshot_time, parse_time, assign_time,
        aggregate_time, total_time)),
      file.path(cache, paste0("benchmark-", method, ".rds")))
    if (is.null(reference_assignment)) {
      reference_assignment <- assignment
      reference_counts <- counts
      saveRDS(records, file.path(cache, "national-parsed.rds"))
      saveRDS(assigned, file.path(cache, "national-assigned.rds"))
      readr::write_csv(contract$coverage, "inst/validation/national-coverage.csv")
      readr::write_csv(
        sl_contract(assigned)$assignment_quality,
        "inst/validation/national-assignment-quality.csv"
      )
      readr::write_csv(
        sl_timestamp_quality(records),
        "inst/validation/national-timestamps.csv"
      )
    } else {
      stopifnot(isTRUE(all.equal(reference_assignment, assignment,
        check.attributes = FALSE, tolerance = 1e-10
      )))
      # Compare every column exactly. Ingestion contracts include run-specific
      # creation times and scopes, so whole-object identity is inappropriate.
      stopifnot(identical(lapply(reference_counts, identity),
        lapply(counts, identity)))
    }
    elapsed <- rbind(
      snapshot_time, parse_time, assign_time,
      aggregate_time, total_time
    )
    timings[[length(timings) + 1L]] <- tibble::tibble(
      replicate = replicate, method = method,
      stage = c(
        "snapshot_verify", "parse_audit", "spatial_assignment",
        "aggregate", "total"
      ),
      user_seconds = elapsed[, 1], system_seconds = elapsed[, 2],
      elapsed_seconds = elapsed[, 3], events = nrow(records),
      submitted_files = nrow(selected), msoa_polygons = nrow(boundaries)
    )
    readr::write_csv(
      dplyr::bind_rows(timings),
      "inst/validation/benchmark-national.csv"
    )
    rm(records, assigned, assignment, counts)
  }
}
jsonlite::write_json(
  list(
    started = as.character(started), finished = as.character(Sys.time()),
    complete = TRUE, exact_assignment_and_count_agreement = TRUE,
    replications = replications, r_version = R.version.string,
    resumed_from_saved_national_run = resuming,
    platform = R.version$platform, system = as.list(Sys.info()),
    events = sum(reference_counts$n), rows = nrow(reference_counts),
    scope = "43 territorial E&W forces, August 2025-July 2026; missing files retained in coverage",
    comparison = "One national local spatial batch versus twelve monthly local batches",
    included = "ZIP and CSV hash verification, snapshot reads, schema parsing, auditing, spatial assignment and aggregation",
    excluded = "Initial network downloads, library loading and writing validation artifacts",
    cache = "ZIP, extracted CSVs and boundaries already present; OS cache and workstation load uncontrolled",
    interpretation = "Measured local run, not a hardware-independent performance guarantee. No API record acquisition."
  ), "inst/validation/benchmark-national-manifest.json",
  pretty = TRUE,
  auto_unbox = TRUE
)
