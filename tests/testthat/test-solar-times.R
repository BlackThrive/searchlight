test_that("solar events match the frozen external reference to the second", {
  reference <- readRDS(test_path("fixtures", "solar-reference.rds"))$solar
  request <- reference[c("date", "lat", "lon")]
  actual <- sl_solar_times(request)
  expect_identical(actual[c("date", "lat", "lon")], request)
  expect_identical(as.numeric(actual$sunset), reference$sunset)
  expect_identical(as.numeric(actual$dusk), reference$dusk)
  expect_true(all(actual$dusk > actual$sunset))

  shuffled <- c(6, 2, 6, 1)
  subset <- sl_solar_times(request[shuffled, ], keep = "dusk")
  expect_identical(as.numeric(subset$dusk), reference$dusk[shuffled])
  expect_identical(names(subset), c("date", "lat", "lon", "dusk"))
})

test_that("all darkness designs retain released classifications and fits", {
  reference <- readRDS(test_path("fixtures", "solar-reference.rds"))$models
  x <- fixture_veil()
  for (i in seq_along(c("intertwilight", "dst"))) {
    design <- c("intertwilight", "dst")[[i]]
    for (j in seq_along(c("civil", "sunset"))) {
      twilight <- c("civil", "sunset")[[j]]
      actual <- sl_veil_of_darkness(x, design = design, twilight = twilight)
      expected <- reference[[i]][[j]]
      for (column in names(expected$summary)) {
        expect_equal(actual[[column]], expected$summary[[column]])
      }
      expect_equal(attr(actual, "steps"), expected$steps)
      data <- as.data.frame(attr(actual, "data")[names(expected$data)])
      # Compare all design columns, excluding the run's provenance timestamp.
      expect_equal(lapply(data, identity), lapply(expected$data, identity))
    }
  }
})

test_that("event instants survive host time zones and UK clock transitions", {
  days <- as.Date(c(
    "2024-02-29", "2026-03-28", "2026-03-29",
    "2026-10-24", "2026-10-25", "2026-12-31"
  ))
  request <- data.frame(date = days, lat = 51.5, lon = -0.1)
  london <- sl_solar_times(request)
  utc <- sl_solar_times(request, tz = "UTC")
  expect_identical(as.numeric(london$dusk), as.numeric(utc$dusk))
  expect_equal(
    format(london$dusk, "%z"),
    c("+0000", "+0000", "+0100", "+0100", "+0000", "+0000")
  )
  expect_equal(as.Date(london$dusk, tz = "Europe/London"), days)
  withr::local_envvar(TZ = "Pacific/Auckland")
  expect_identical(sl_solar_times(request), london)

  x <- fixture_veil()[1:5, ]
  sun <- london[london$date == as.Date("2026-03-29"), ]
  x$date <- as.POSIXct(
    c(
      as.numeric(sun$sunset) + c(-1, 0),
      as.numeric(sun$dusk) + c(-1, 0, 1)
    ),
    origin = "1970-01-01", tz = "Europe/London"
  )
  data <- sl_sun_design(x, "civil")
  expect_identical(data$dark, c(0L, 0L, 0L, 1L, 1L))
  expect_identical(
    data$date < data$sunset | data$date >= data$dusk,
    c(TRUE, FALSE, FALSE, TRUE, TRUE)
  )
})

test_that("unavailable solar crossings and empty requests remain explicit", {
  polar <- data.frame(
    date = as.Date(c("2026-06-21", "2026-12-21")),
    lat = c(89, 89), lon = c(0, 0)
  )
  expect_silent(sun <- sl_solar_times(polar))
  expect_true(all(is.na(sun$sunset)))
  expect_true(all(is.na(sun$dusk)))
  expect_error(sl_annual_sun_bounds(data.frame(
    latitude = 89, longitude = 0, year = 2026, location = 1
  ), "dusk"), "unavailable")
  empty <- sl_solar_times(polar[FALSE, ])
  expect_equal(nrow(empty), 0L)
  expect_s3_class(empty$dusk, "POSIXct")
  expect_error(sl_solar_times(transform(polar, lat = NA_real_)), "Invalid")
  expect_error(sl_solar_times(transform(polar, lat = 91)), "Invalid")
  expect_error(sl_solar_times(polar, keep = "moonrise"), "Invalid")
  expect_error(sl_solar_times(polar, tz = "not-a-time-zone"), "time zone")
})
