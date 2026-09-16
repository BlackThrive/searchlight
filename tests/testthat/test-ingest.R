test_that("whole-file version selection preserves duplicate events", {
  d <- withr::local_tempdir()
  fixture_zip(d, "2026-06", 3)
  fixture_zip(d, "2026-07", 4)
  v <- sl_archive_snapshot(d)
  expect_equal(nrow(v), 4L)
  expect_equal(sl_list_versions(d), v)
  latest <- sl_select_version(v)
  expect_equal(latest$n_records, c(4L, 4L))
  expect_equal(nrow(attr(latest, "differences")), 2L)
  expect_equal(sl_select_version(v, "earliest")$n_records, c(3L, 3L))
  expect_equal(sl_select_version(v, "max_rows")$n_records, c(4L, 4L))
  manual <- latest[c("force_id", "month", "archive_file")]
  expect_equal(sl_select_version(v, "manual", manual)$n_records, c(4L, 4L))
  expect_error(sl_select_version(v, "manual", manual[1, ]),
    class = "searchlight_error_input"
  )
  expect_error(sl_select_version(rbind(v, v)),
    class = "searchlight_error_input"
  )
  x <- sl_read_records(d, latest)
  expect_equal(nrow(x), 8L)
  expect_true(any(duplicated(as.data.frame(x))))
  expect_s3_class(x, "sl_records")
  expect_equal(class(x), c("sl_records", "tbl_df", "tbl", "data.frame"))
  expect_equal(nrow(sl_contract(x)$versions), 2L)
  expect_true(all(sl_contract(x)$coverage$status == "refreshed"))
  expect_false(any(grepl("street.csv", list.files(d, recursive = TRUE)[
    grepl("snapshots", list.files(d, recursive = TRUE))
  ], fixed = TRUE)))
  expect_equal(sl_archive_snapshot(d), v)
})

test_that("bundled sample retains the missing requested force", {
  x <- sl_sample()
  expect_equal(nrow(x), 4657L)
  coverage <- summary(sl_contract(x))
  expect_equal(nrow(coverage), 6L)
  missing <- coverage[coverage$force_id == "dyfed-powys", ]
  expect_equal(missing$status, rep("missing", 3))
  expect_true(all(is.na(missing$n_records)))
  expect_true(all(grepl("^[a-f0-9]{64}$", sl_contract(x)$snapshots$sha256)))
})

test_that("offset conversion retains filename month at calendar boundaries", {
  d <- withr::local_tempdir()
  records <- fixture_records(d)
  versions <- sl_contract(records)$versions[1, ]
  path <- file.path(d, versions$csv_path)
  raw <- fixture_rows()
  raw$Date[1] <- "2026-06-30T23:30:00+00:00"
  readr::write_csv(raw, path)
  versions$csv_sha256 <- sl_hash(path)
  parsed <- sl_read_records(d, versions)
  expect_equal(parsed$month, rep("2026-06", 3))
  expect_equal(format(
    parsed$date[1], "%Y-%m-%d %H:%M",
    tz = "Europe/London"
  ), "2026-07-01 00:30")
  expect_equal(parsed$date_month_crossing, c(TRUE, FALSE, FALSE))
  expect_equal(
    sl_contract(parsed)$timestamps$london_month_mismatch_share,
    1 / 3
  )
  raw$Date[1] <- "2026-07-12T12:30:00+00:00"
  readr::write_csv(raw, path)
  versions$csv_sha256 <- sl_hash(path)
  expect_error(sl_read_records(d, versions), "filename month")
})

test_that("an explicitly empty CSV is different from an absent CSV", {
  d <- withr::local_tempdir()
  fixture_zip(d, n = 0L)
  sl_archive_snapshot(d)
  x <- sl_read_records(d)
  expect_equal(nrow(x), 0L)
  expect_true(all(sl_contract(x)$coverage$status == "submitted"))
  expect_equal(sl_contract(x)$coverage$n_records, c(0L, 0L))
})

test_that(
  "raw fields, Unknown, offsets, and separate outcomes survive parsing",
  {
    d <- withr::local_tempdir()
    x <- fixture_records(d)
    expect_equal(as.character(x$ethnicity_5), rep(c(
      "White", "Black",
      "Unknown"
    ), 2))
    expect_true(all(x$ethnicity_officer == "White"))
    expect_equal(x$self_defined_ethnicity_raw, rep(c("W1", "B2", "NS"), 2))
    expect_equal(x$any_action, rep(c(FALSE, TRUE, NA), 2))
    expect_equal(x$arrest, rep(c(FALSE, TRUE, NA), 2))
    expect_equal(x$outcome_linked_to_object, rep(c(FALSE, TRUE, NA), 2))
    expect_true(all(format(x$date, "%H:%M", tz = "Europe/London") == "13:30"))
    expect_equal(attr(x$date, "tzone"), "Europe/London")
    expect_true(all(x$legislation_group == "PACE s.1"))
    expect_true(all(sl_contract(x)$timestamps$time_reliable))
    expect_s3_class(sl_contract(x), "sl_contract")
    expect_equal(summary(sl_contract(x)), sl_contract(x)$coverage)
    expect_message(print(sl_contract(x)), "ingestion contract")
    expect_error(sl_contract(tibble::tibble()),
      class = "searchlight_error_contract"
    )
  }
)

test_that("contracts propagate through subset, filter, mutate and grouping", {
  d <- withr::local_tempdir()
  x <- fixture_records(d)
  y <- x[1:2, ]
  expect_equal(sl_contract(y)$snapshots, sl_contract(x)$snapshots)
  expect_equal(sl_contract(y)$scope$n_rows, 2L)
  expect_equal(sl_contract(dplyr::filter(
    x,
    .data$ethnicity_5 == "Unknown"
  ))$scope$n_rows, 2L)
  mutated <- dplyr::mutate(x, marker = TRUE)
  expect_equal(sl_contract(mutated)$versions, sl_contract(x)$versions)
  expect_s3_class(dplyr::group_by(x, .data$force_id), "grouped_df")
  expect_equal(sl_contract(dplyr::group_by(
    x,
    .data$force_id
  ))$versions, sl_contract(x)$versions)
  expect_true(is.factor(x[, "ethnicity_5", drop = TRUE]))
})

test_that("checksum changes and absent manifests fail explicitly", {
  d <- withr::local_tempdir()
  expect_error(sl_list_versions(d), class = "searchlight_error_input")
  expect_error(sl_archive_snapshot(d), class = "searchlight_error_input")
  x <- fixture_records(d)
  v <- sl_contract(x)$versions
  writeLines("corrupted", file.path(d, v$csv_path[1]))
  expect_error(sl_read_records(d, v), class = "searchlight_error_integrity")
  expect_error(sl_archive_snapshot(d), class = "searchlight_error_integrity")
})

test_that("cache clearing is scoped and requires a marker", {
  d <- withr::local_tempdir()
  withr::local_options(searchlight.cache_dir = d)
  expect_equal(sl_cache_dir(), d)
  expect_error(sl_cache_clear(d), class = "searchlight_error_input")
  sl_prepare_cache(d)
  writeLines("keep me", file.path(d, "user-file.txt"))
  saveRDS(1, file.path(d, "archive-index.rds"))
  sl_cache_clear(d)
  expect_true(file.exists(file.path(d, "user-file.txt")))
  expect_false(file.exists(file.path(d, "archive-index.rds")))
})

test_that("live resources are gracefully unavailable offline", {
  d <- withr::local_tempdir()
  withr::local_envvar(NO_INTERNET_TEST = "true")
  expect_message(expect_null(sl_archive_index(d)), "Network disabled")
  expect_message(
    expect_null(sl_archive_download("2026-06", dir = d)), "Network disabled"
  )
  expect_error(sl_archive_download("2026-99", dir = d),
    class = "searchlight_error_input"
  )
  expect_error(sl_archive_download("2026-06", "invented", d),
    class = "searchlight_error_input"
  )
})

test_that("archive HTML is tested without a network connection", {
  d <- withr::local_tempdir()
  withr::local_envvar(NO_INTERNET_TEST = "")
  httptest2::with_mock_api({
    x <- sl_archive_index(d)
    expect_s3_class(x, "tbl_df")
    expect_equal(x$archive_file[1], "2026-07.zip")
    expect_equal(x$month_start[1], "2023-08")
    expect_equal(x$month_end[1], "2026-07")
    expect_equal(sl_archive_index(d), x)
  })
})

test_that(
  "verified local archives are reused and minimum coverage is selected",
  {
    d <- withr::local_tempdir()
    path <- fixture_zip(d)
    index <- tibble::tibble(
      archive_file = "2026-06.zip", snapshot_month = "2026-06",
      month_start = "2023-07", month_end = "2026-06",
      url = "https://data.police.uk/data/archive/2026-06.zip",
      md5 = sl_hash(path, "md5")
    )
    manifest <- sl_archive_download(c("2026-05", "2026-06"),
      dir = d,
      index = index
    )
    expect_equal(nrow(manifest), 1L)
    repeated <- sl_archive_download(c("2026-05", "2026-06"),
      dir = d, index = index
    )
    expect_equal(repeated, manifest)
    expect_match(manifest$sha256, "^[a-f0-9]{64}$")
    expect_error(
      sl_archive_download("2020-01", dir = d, index = index),
      class = "searchlight_error_input"
    )
    writeLines("broken", path)
    expect_error(
      sl_archive_download("2026-06", dir = d, index = index),
      class = "searchlight_error_integrity"
    )
  }
)
