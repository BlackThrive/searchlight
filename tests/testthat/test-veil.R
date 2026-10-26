test_that("unreliable or absent timestamp audits gate all affected records", {
  x <- fixture_veil()
  attr(x, "contract")$timestamps$time_reliable <- FALSE
  result <- sl_veil_of_darkness(x)
  expect_equal(result$n, 0)
  expect_true(is.na(result$odds_ratio))
  expect_equal(nrow(attr(result, "excluded_force_months")), 12)
  attr(x, "contract")$timestamps <- tibble::tibble()
  expect_equal(sl_veil_of_darkness(x)$n, 0)
  x$date <- as.POSIXct(paste(as.Date(x$date), "00:00:00"), tz = "Europe/London")
  x$date_raw <- format(x$date, "%Y-%m-%dT%H:%M:%S%z")
  quality <- sl_timestamp_quality(x)
  attr(x, "contract")$timestamps <- quality
  expect_true(all(!quality$time_reliable))
  expect_equal(sl_veil_of_darkness(x)$n, 0)
})

test_that("batched annual solar bounds retain the released reference values", {
  reference <- readRDS(test_path("fixtures", "solar-reference.rds"))
  locations <- reference$locations
  for (selected in c("sunset", "dusk")) {
    batched <- sl_annual_sun_bounds(locations, selected)
    expect_equal(batched, reference$bounds[[selected]])
  }
})

test_that("UK DST, local clock time and astronomical definitions agree", {
  expect_equal(sl_dst_dates(2026), as.Date(c("2026-03-29", "2026-10-25")))
  utc <- as.POSIXct(c("2026-03-28 18:00:00", "2026-03-29 18:00:00"), tz = "UTC")
  expect_equal(sl_clock_minutes(utc), c(18, 19) * 60)
  x <- fixture_veil()
  result <- sl_veil_of_darkness(x)
  data <- attr(result, "data")
  expect_gt(nrow(data), 500)
  expect_true(all(data$date < data$sunset | data$date >= data$dusk))
  expect_equal(data$dark, as.integer(data$date >= data$dusk))
  expect_equal(result$dark_stops + result$daylight_stops, result$n)
  expect_equal(result$status, "estimable")
  expect_true(result$conf_low < 1 & result$conf_high > 1)
  expect_true(all(diff(attr(result, "steps")$remaining) <= 0))
  expect_gte(length(attr(result, "assumptions")), 5)
  dst <- sl_veil_of_darkness(x, design = "dst", twilight = "sunset")
  d <- attr(dst, "data")
  expect_true(all(abs(d$days_from_transition) <= 21))
  expect_equal(d$dark, as.integer(d$date >= d$sunset))
  expect_lt(dst$n, result$n)
  attr(x, "contract")$timestamps$time_reliable[1] <- FALSE
  expect_equal(nrow(attr(sl_veil_of_darkness(x), "excluded_force_months")), 1)
  expect_error(sl_veil_of_darkness(x, window = "all"), "window")
})
