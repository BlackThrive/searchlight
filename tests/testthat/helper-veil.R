fixture_veil <- function() {
  days <- seq(as.Date("2026-01-01"), as.Date("2026-12-31"), by = "day")
  grid <- expand.grid(day = days, time = c(
    "17:30:00", "18:30:00", "19:30:00",
    "20:30:00"
  ), stringsAsFactors = FALSE)
  date <- as.POSIXct(paste(grid$day, grid$time), tz = "Europe/London")
  x <- tibble::tibble(
    date = date, date_raw = format(date, "%Y-%m-%dT%H:%M:%S%z"),
    month = format(date, "%Y-%m", tz = "Europe/London"),
    force_id = "synthetic", latitude = 51.5, longitude = -0.1,
    ethnicity_5 = rep(c("White", "Black", "Black", "White"),
      length.out = length(date)
    )
  )
  contract <- sl_new_contract()
  contract$source <- "synthetic darkness fixture"
  contract$coverage <- unique(x[c("force_id", "month")])
  contract$coverage$status <- "submitted"
  contract$timestamps <- contract$coverage[c("force_id", "month")]
  contract$timestamps$time_reliable <- TRUE
  sl_carry(x, contract, "sl_records")
}
