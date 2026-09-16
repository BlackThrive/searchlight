test_that(
  "download uses mocked HTTP, verifies publisher hash and records request",
  {
    staging <- withr::local_tempdir()
    target <- withr::local_tempdir()
    mocks <- withr::local_tempdir()
    path <- fixture_zip(staging)
    response_path <- file.path(mocks, "data.police.uk", "data", "archive")
    dir.create(response_path, recursive = TRUE)
    file.copy(path, file.path(response_path, "2026-06.zip.txt"))
    index <- tibble::tibble(
      archive_file = "2026-06.zip", snapshot_month = "2026-06",
      month_start = "2023-07", month_end = "2026-06",
      url = "https://data.police.uk/data/archive/2026-06.zip",
      md5 = sl_hash(path, "md5")
    )
    withr::local_envvar(NO_INTERNET_TEST = "")
    httptest2::with_mock_dir(mocks, {
      manifest <- sl_archive_download(
        "2026-06", "west-yorkshire",
        target, index
      )
      expect_equal(manifest$sha256, sl_hash(path))
      expect_equal(manifest$requested_forces, list("west-yorkshire"))
      versions <- sl_archive_snapshot(target)
      expect_equal(versions$force_id, "west-yorkshire")
      records <- sl_read_records(target)
      expect_equal(nrow(records), 3L)
      expect_equal(sl_contract(records)$snapshots$url, index$url)
    })
    bad_target <- withr::local_tempdir()
    index$md5 <- paste(rep("0", 32), collapse = "")
    httptest2::with_mock_dir(mocks, {
      expect_error(
        sl_archive_download("2026-06", dir = bad_target, index = index),
        class = "searchlight_error_integrity"
      )
    })
    expect_false(file.exists(file.path(bad_target, "2026-06.zip")))
    expect_length(list.files(bad_target, pattern = "part$"), 0L)
    httptest2::without_internet({
      expect_null(sl_archive_index(withr::local_tempdir()))
    })
  }
)

test_that("zero-row source is retained and timestamp gate is conservative", {
  mapping <- sl_map_ethnicity(c("W4", "O1", NA, "not stated", "Refused"))
  expect_equal(as.character(mapping$ethnicity_19), c(
    "Roma", "Arab",
    rep("Unknown", 3)
  ))
  x <- tibble::tibble(
    force_id = "dyfed-powys", month = "2026-06",
    date = as.POSIXct(c("2026-06-01 00:00:00", NA), tz = "Europe/London")
  )
  quality <- sl_time_summary(x, 0.05)
  expect_false(quality$time_reliable)
  expect_equal(quality$midnight_share, 1)
  expect_equal(quality$missing_time_share, 0.5)
  expect_error(sl_bool("not a boolean"), class = "searchlight_error_schema")
})
