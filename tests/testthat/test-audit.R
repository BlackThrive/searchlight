test_that("coverage distinguishes absent, zero, refreshed and partial", {
  x <- sl_sample()[1:2, ]
  ct <- sl_contract(x)
  v <- ct$versions[rep(1, 4), ]
  v$month <- c("2026-01", "2026-02", "2026-03", "2026-04")
  v$n_records <- c(100L, 90L, 10L, 0L)
  v$alternatives <- lapply(v$n_records, function(n) {
    tibble::tibble(n_records = n)
  })
  v$alternatives[[2]] <- tibble::tibble(n_records = c(50L, 90L))
  ct$versions <- v
  ct$requested <- tidyr::expand_grid(
    force_id = "west-yorkshire",
    month = sprintf("2026-%02d", 1:5)
  )
  x <- sl_carry(x, ct)
  empty <- tibble::tibble(
    force_id = character(), month = character(),
    note = character()
  )
  cov <- sl_coverage(x, changelog = empty)
  expect_equal(cov$status, c(
    "submitted", "refreshed", "partial_suspected",
    "partial_suspected", "missing"
  ))
  expect_equal(cov$n_records, c(100L, 90L, 10L, 0L, NA_integer_))
  expect_equal(sl_contract(cov)$coverage$n_records, cov$n_records)
  ct$versions$n_records[1] <- 0L
  x <- sl_carry(x, ct)
  expect_equal(sl_coverage(x, changelog = empty)$status[1], "submitted")
  notes <- tibble::tibble(
    force_id = "west-yorkshire", month = "2026-02",
    note = "source issue", issue = TRUE
  )
  expect_equal(sl_coverage(x, changelog = notes)$status[2], "partial_suspected")
  expect_error(sl_coverage(x, partial_threshold = -1))
  expect_s3_class(plot(cov), "ggplot")
  comparison <- sl_coverage_compare(cov, "2026-01", "2026-02")
  expect_true(comparison$comparable)
  expect_false(sl_coverage_compare(cov, "2026-01", "2026-05")$comparable)
  expect_false(sl_coverage_compare(cov, "2026-05", "2026-06")$comparable)
  expect_false(sl_coverage_compare(
    cov, c("2026-01", "2026-02"),
    "2026-01"
  )$comparable)
})

test_that("annual benchmarks never compare partial years", {
  x <- sl_sample()[rep(1, 12), ]
  x$month <- format(
    seq(as.Date("2024-04-01"), by = "month", length.out = 12),
    "%Y-%m"
  )
  ct <- sl_contract(x)
  ct$coverage <- tibble::tibble(
    force_id = "west-yorkshire", month = x$month,
    status = "submitted", n_records = 1L
  )
  x <- sl_carry(x, ct)
  p <- tibble::tibble(
    force_id = "west-yorkshire", year_end = 2025,
    published_total = 10
  )
  b <- sl_benchmark(x, p)
  expect_true(b$complete)
  expect_equal(b$ratio, 1.2)
  expect_true(b$beyond_tolerance)
  expect_false(sl_benchmark(x[-1, ], p)$complete)
  expect_true(all(is.na(sl_benchmark(sl_sample())$ratio)))
  expect_error(sl_benchmark(x, p, -1))
})

test_that("source midnight is gated across British summer time", {
  x <- sl_sample()[1:3, ]
  x$force_id <- "west-yorkshire"
  x$month <- "2026-06"
  x$date_raw <- "2026-06-01T00:00:00+00:00"
  x$date <- as.POSIXct("2026-06-01 00:00:00", tz = "UTC")
  q <- sl_timestamp_quality(x)
  row <- q[q$force_id == "west-yorkshire" & q$month == "2026-06", ]
  expect_equal(row$midnight_share, 0)
  expect_equal(row$source_midnight_share, 1)
  expect_false(row$time_reliable)
  expect_false(any(sl_timestamp_quality(x[FALSE, ])$time_reliable))
  expect_error(sl_timestamp_quality(x, 2))
  x$latitude <- c(53.8, 53.8, NA)
  x$longitude <- c(-1.5, -1.5, NA)
  x$lsoa21 <- "area"
  loc <- sl_location_quality(x)
  expect_equal(loc$missing_coordinate_share, 1 / 3)
  expect_equal(loc$snap_point_concentration, 1)
  x$latitude <- NA_real_
  expect_true(is.na(sl_location_quality(x)$snap_point_concentration))
  pop <- sl_exposure(tibble::tibble(
    geography_code = "area", ethnicity = "White",
    population = 100
  ), "lsoa21")
  audited <- sl_quality(x, pop)
  expect_equal(sl_contract(audited)$population$source, "user_supplied")
  expect_true(nrow(sl_contract(audited)$location_quality) > 0)
})
