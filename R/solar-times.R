# Solar-event equations adapted from SunCalc.js 1.9.0 (BSD-2-Clause).
# Copyright (c) 2014, Vladimir Agafonkin. See inst/COPYRIGHTS for the notice.
# Source: https://github.com/mourner/suncalc/tree/v1.9.0
# The R implementation here only calculates sunset and civil dusk at sea level.

#' @noRd
sl_solar_times <- function(data, keep = c("sunset", "dusk"),
                           tz = "Europe/London") {
  sl_require_columns(data, c("date", "lat", "lon"))
  valid <- inherits(data$date, "Date") && is.numeric(data$lat) &&
    is.numeric(data$lon) && all(is.finite(as.numeric(data$date))) &&
    all(is.finite(data$lat) & abs(data$lat) <= 90) &&
    all(is.finite(data$lon) & abs(data$lon) <= 180) &&
    length(keep) > 0L && !anyNA(keep) &&
    all(keep %in% c("sunset", "dusk")) && !anyDuplicated(keep)
  if (!valid) {
    sl_abort("Invalid dates, coordinates or solar-event names.")
  }
  if (length(tz) != 1L || is.na(tz) || !tz %in% OlsonNames()) {
    sl_abort("Use a named time zone for solar events.")
  }
  rad <- pi / 180
  west <- -data$lon * rad
  latitude <- data$lat * rad
  # Date denotes the requested calendar day. Anchor at noon UTC, independently
  # of the host time zone. Express event instants in the requested output zone.
  days <- as.numeric(data$date) + 2440588 - 2451545
  cycle <- floor(days - 0.0009 - west / (2 * pi) + 0.5)
  transit <- 0.0009 + west / (2 * pi) + cycle
  anomaly <- rad * (357.5291 + 0.98560028 * transit)
  centre <- 1.9148 * sin(anomaly) + 0.02 * sin(2 * anomaly) +
    0.0003 * sin(3 * anomaly)
  longitude <- anomaly + rad * centre + rad * 102.9372 + pi
  declination <- asin(sin(rad * 23.4397) * sin(longitude))
  correction <- 0.0053 * sin(anomaly) - 0.0069 * sin(2 * longitude)
  elevations <- c(sunset = -0.833, dusk = -6)
  result <- as.data.frame(data[c("date", "lat", "lon")])
  for (event in keep) {
    numerator <- sin(elevations[[event]] * rad) -
      sin(latitude) * sin(declination)
    cosine <- numerator / (cos(latitude) * cos(declination))
    # No crossing occurs during polar day/night. Retain NA rather than clamping
    # a physically unavailable event to an artificial horizon crossing.
    available <- is.finite(cosine) & abs(cosine) <= 1
    angle <- rep(NA_real_, nrow(result))
    angle[available] <- acos(cosine[available])
    julian <- 2451545 + 0.0009 + (angle + west) / (2 * pi) + cycle + correction
    seconds <- floor((julian + 0.5 - 2440588) * 86400)
    result[[event]] <- as.POSIXct(seconds, origin = "1970-01-01", tz = tz)
  }
  result
}
