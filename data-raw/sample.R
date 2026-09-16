# Explicit network-enabled build script, never sourced during package check.
# Run from the repository root. No record acquisition API is used.
devtools::load_all(quiet = TRUE)
cache <- normalizePath(".cache", winslash = "/", mustWork = TRUE)
index <- sl_archive_index(cache, refresh = TRUE)
stopifnot(!is.null(index))
latest <- max(index$month_end)
months <- format(seq(as.Date(paste0(latest, "-01")),
  by = "-1 month", length.out = 3
), "%Y-%m")
forces <- c("west-yorkshire", "dyfed-powys")
manifest <- sl_archive_download(months, forces, cache, index)
stopifnot(!is.null(manifest))
versions <- sl_archive_snapshot(cache, months, forces)
versions <- versions[versions$month %in% months & versions$force_id %in% forces, ]
versions$source_csv_sha256 <- versions$csv_sha256
sample_dir <- file.path("inst", "extdata", "sample")
dir.create(sample_dir, recursive = TRUE, showWarnings = FALSE)
for (i in seq_len(nrow(versions))) {
  source <- file.path(cache, versions$csv_path[i])
  destination <- file.path(versions$month[i], paste0(basename(source), ".gz"))
  dir.create(file.path(sample_dir, versions$month[i]), showWarnings = FALSE)
  input <- readBin(source, "raw", n = file.info(source)$size)
  output <- gzfile(file.path(sample_dir, destination), "wb", compression = 9)
  writeBin(input, output)
  close(output)
  versions$source_csv_sha256[i] <- versions$csv_sha256[i]
  versions$csv_path[i] <- destination
  versions$csv_sha256[i] <- digest::digest(
    file = file.path(sample_dir, destination), algo = "sha256"
  )
}
saveRDS(versions, file.path(sample_dir, "snapshot-manifest.rds"), version = 2)
saveRDS(manifest, file.path(sample_dir, "archive-manifest.rds"), version = 2)
saveRDS(index[1:3, ], "inst/extdata/archive-index.rds", version = 2)
records <- sl_read_records(sample_dir)
saveRDS(records, "inst/extdata/sample-records.rds", compress = "xz", version = 2)
print(table(records$force_id, records$month))
print(sl_contract(records))
writeLines(c(
  paste("Built:", format(Sys.time(), tz = "UTC")),
  paste("Archive:", manifest$archive_file),
  paste("Archive SHA-256:", manifest$sha256),
  paste("Records:", nrow(records)),
  paste("Months:", paste(sort(months), collapse = ", ")),
  "CSV contents are unmodified, gzip-compressed. Original and stored hashes retained."
), file.path(sample_dir, "provenance.txt"))
