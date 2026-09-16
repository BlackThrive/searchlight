#' Diagnose ethnicity composition in daylight and darkness
#'
#' Excludes every force-month that fails or lacks the contract's time-quality
#' screen, retaining an explicit exclusion table. Annual evening
#'   clock-time bounds
#' use each distinct location and year. Civil darkness begins at dusk;
#'   ambiguous
#' sunset-to-dusk observations are excluded. Times and clock changes use
#' Europe/London, including British summer time. The logistic comparison
#'   controls
#' clock time (natural spline), weekday, month and force where these vary.
#' The DST option further restricts to weeks around both clock changes and
#'   adds
#' transition and running-day controls; it is a local darkness comparison.
#' The method was developed for vehicle stops. Transfer to pedestrian searches
#' requires assumptions about visibility, activity, deployment and selection.
#' @param records Contract-bearing search records.
#' @param boundaries Optional sf study region; restrict published points
#'   to it.
#'   Missing locations are never replaced by centroids.
#' @param twilight Civil twilight end or sunset definition of darkness.
#' @param window Currently only intertwilight, the annual evening overlap
#'   window.
#' @param design Annual intertwilight or local DST-window comparison.
#' @param reference,comparison Known self-defined ethnicity groups.
#' @param dst_weeks Weeks on either side of each clock change for the DST
#'   design.
#' @param conf_level Logistic Wald confidence level.
#' @return An sl_veil tibble with an odds ratio, interval and fit status.
#'   Attributes steps, excluded_force_months, assumptions, data and model
#'   retain
#'   the full design audit. A gated or unidentifiable sample has an
#'   undefined ratio.
#' @family inference
#' @importFrom splines ns
#' @seealso [sl_timestamp_quality()], [sl_hit_rates()]
#' @export
#' @examples
#' # Date-only records are explicitly refused by the time-quality screen.
#' x <- sl_sample()[1:10, ]
#' day <- as.Date(x$date, tz = "Europe/London")
#' x$date <- as.POSIXct(paste(day, "00:00:00"), tz = "Europe/London")
#' x$date_raw <- format(x$date, "%Y-%m-%dT%H:%M:%S%z")
#' attr(x, "contract")$timestamps <- sl_timestamp_quality(x)
#' sl_veil_of_darkness(x)
sl_veil_of_darkness <- function(records, boundaries = NULL,
                                twilight = c("civil", "sunset"),
                                window = "intertwilight",
                                design = c("intertwilight", "dst"),
                                reference = "White", comparison = "Black",
                                dst_weeks = 3, conf_level = 0.95) {
  twilight <- match.arg(twilight)
  design <- match.arg(design)
  sl_validate_pair(reference, comparison, conf_level)
  invalid <- !identical(window, "intertwilight") || length(dst_weeks) != 1L ||
    !is.finite(dst_weeks) || dst_weeks <= 0
  if (invalid) {
    sl_abort("Invalid darkness window.")
  }
  contract <- sl_contract(records)
  sl_require_columns(records, c(
    "date", "force_id", "month", "latitude",
    "longitude", "ethnicity_5"
  ))
  if (!inherits(records$date, "POSIXct")) {
    sl_abort("date must contain instants.")
  }
  data <- tibble::as_tibble(records)
  steps <- tibble::tibble(stage = "input", remaining = nrow(data))
  keys <- c("force_id", "month")
  source <- unique(data[keys])
  times <- contract$timestamps
  if (all(c(keys, "time_reliable") %in% names(times))) {
    times <- times[c(keys, "time_reliable")]
    source <- dplyr::left_join(source, times, by = keys)
  } else {
    source$time_reliable <- FALSE
  }
  bad <- is.na(source$time_reliable) | !source$time_reliable
  excluded <- source[bad, ]
  data <- dplyr::semi_join(data, source[!bad, ], by = keys)
  steps <- sl_veil_step(steps, "reliable force-month time", data)
  if (nrow(excluded)) {
    cli::cli_inform("Excluded {nrow(excluded)} unreliable force-month(s).")
  }
  valid <- sl_valid_coordinates(data) & !is.na(data$date)
  data <- data[valid, ]
  if (!is.null(boundaries) && nrow(data)) {
    points <- sf::st_as_sf(as.data.frame(data),
      coords = c("longitude", "latitude"),
      crs = 4326
    )
    b <- sf::st_transform(sf::st_make_valid(boundaries), 27700)
    intersections <- sf::st_intersects(sf::st_transform(points, 27700), b)
    within <- lengths(intersections) > 0
    data <- data[within, ]
  }
  steps <- sl_veil_step(steps, "valid location and instant", data)
  data <- data[data$ethnicity_5 %in% c(reference, comparison), ]
  steps <- sl_veil_step(steps, "known comparison pair", data)
  data$.outcome <- as.integer(data$ethnicity_5 == comparison)
  data$dark <- integer(nrow(data))
  controls <- character()
  if (nrow(data)) {
    data <- sl_sun_design(data, twilight)
    inside <- data$clock_minute >= data$earliest &
      data$clock_minute <= data$latest
    data <- data[inside, ]
    steps <- dplyr::add_row(steps,
      stage = "annual intertwilight clock window",
      remaining = nrow(data)
    )
    if (twilight == "civil") {
      data <- data[data$date < data$sunset | data$date >= data$dusk, ]
    }
    steps <- dplyr::add_row(steps,
      stage = "unambiguous daylight or darkness",
      remaining = nrow(data)
    )
    if (design == "dst" && nrow(data)) {
      data <- sl_dst_design(data, dst_weeks)
    }
    steps <- sl_veil_step(steps, "design window", data)
    if (nrow(data)) {
      data$weekday <- factor(format(data$date, "%u", tz = "Europe/London"))
      month <- format(data$date, "%Y-%m", tz = "Europe/London")
      data$calendar_month <- factor(month)
      data$force_id <- factor(data$force_id)
      candidate <- c("weekday", "calendar_month", "force_id")
      controls <- candidate[vapply(
        data[candidate], function(x) length(unique(x)) > 1,
        logical(1)
      )]
      if (length(unique(data$clock_minute)) >= 5) {
        controls <- c(controls, "splines::ns(clock_minute, df = 3)")
      } else if (length(unique(data$clock_minute)) > 1) {
        controls <- c(controls, "clock_minute")
      }
      if (design == "dst") {
        controls <- c(controls, "days_from_transition")
        if (length(unique(data$transition)) > 1) {
          controls <- c(controls, "transition")
        }
      }
    }
  }
  formula <- stats::reformulate(c("dark", controls), response = ".outcome")
  fitted <- sl_logistic(data, formula, "dark", conf_level)
  result <- fitted$summary
  result$reference <- reference
  result$comparison <- comparison
  result$design <- design
  result$twilight <- twilight
  result$dark_stops <- sum(data$dark)
  result$daylight_stops <- nrow(data) - result$dark_stops
  result <- sl_carry(result, contract, "sl_veil")
  attr(result, "model") <- fitted$model
  attr(result, "data") <- data
  attr(result, "steps") <- steps
  attr(result, "excluded_force_months") <- excluded
  attr(result, "assumptions") <- c(
    "Darkness reduces visibility of ethnicity before the stop.",
    "Activity, exposure and police deployment are comparable after controls.",
    "Reporting does not vary differentially by darkness and ethnicity.",
    "Times, locations and self-defined ethnicity are measured adequately.",
    "Enough daylight/darkness overlap remains after controls.",
    "Repeated events and unmeasured selection can violate model independence.",
    "A vehicle-stop method needs justification for pedestrian searches."
  )
  result
}

#' @noRd
sl_sun_design <- function(data, twilight) {
  local_date <- format(data$date, "%Y-%m-%d", tz = "Europe/London")
  data$local_date <- as.Date(local_date)
  data$year <- as.integer(format(data$local_date, "%Y"))
  locations <- unique(as.data.frame(data)[c("latitude", "longitude", "year")])
  locations$location <- seq_len(nrow(locations))
  data <- dplyr::left_join(data, locations,
    by = c("latitude", "longitude", "year")
  )
  selected <- if (twilight == "civil") "dusk" else "sunset"
  bounds <- sl_annual_sun_bounds(locations, selected)
  data <- dplyr::left_join(data, bounds, by = "location")
  request <- unique(data.frame(
    date = data$local_date, lat = data$latitude,
    lon = data$longitude
  ))
  sun <- suncalc::getSunlightTimes(
    data = request, keep = c("sunset", "dusk"),
    tz = "Europe/London"
  )
  names(sun)[names(sun) == "date"] <- "local_date"
  names(sun)[names(sun) == "lat"] <- "latitude"
  names(sun)[names(sun) == "lon"] <- "longitude"
  data <- dplyr::left_join(data, sun,
    by = c("local_date", "latitude", "longitude")
  )
  data$clock_minute <- sl_clock_minutes(data$date)
  data$dark <- as.integer(data$date >= data[[selected]])
  data
}

#' @noRd
sl_annual_sun_bounds <- function(locations, selected) {
  # Exact locations and every calendar day are retained. Bounded batches avoid
  # thousands of separate solar calls without a national-sized Cartesian table.
  index <- seq_len(nrow(locations))
  batches <- split(index, (index - 1L) %/% 64L)
  results <- lapply(batches, function(batch) {
    request <- dplyr::bind_rows(lapply(batch, function(i) {
      row <- locations[i, ]
      dates <- seq(as.Date(paste0(row$year, "-01-01")),
        as.Date(paste0(row$year, "-12-31")),
        by = "day"
      )
      data.frame(
        date = dates, lat = row$latitude, lon = row$longitude,
        location = row$location
      )
    }))
    keys <- c("date", "lat", "lon")
    sun <- suncalc::getSunlightTimes(
      data = as.data.frame(request[keys]),
      keep = selected, tz = "Europe/London"
    )
    sun <- dplyr::left_join(sun, request, by = keys)
    sun$clock <- sl_clock_minutes(sun[[selected]])
    if (any(!is.finite(sun$clock))) {
      sl_abort(
        "Annual twilight is unavailable at a supplied location.", "model"
      )
    }
    dplyr::summarise(dplyr::group_by(sun, .data$location),
      earliest = min(.data$clock), latest = max(.data$clock), .groups = "drop"
    )
  })
  dplyr::bind_rows(results)
}

#' @noRd
sl_veil_step <- function(steps, stage, data) {
  dplyr::add_row(steps, stage = stage, remaining = nrow(data))
}

#' @noRd
sl_clock_minutes <- function(x) {
  as.numeric(format(x, "%H", tz = "Europe/London")) * 60 +
    as.numeric(format(x, "%M", tz = "Europe/London")) +
    as.numeric(format(x, "%S", tz = "Europe/London")) / 60
}

#' @noRd
sl_dst_dates <- function(year) {
  dates <- seq(as.Date(paste0(year, "-01-01")),
    as.Date(paste0(year, "-12-31")),
    by = "day"
  )
  noon <- as.POSIXct(paste(dates, "12:00:00"), tz = "Europe/London")
  offset <- format(noon, "%z", tz = "Europe/London")
  dates[c(FALSE, offset[-1] != offset[-length(offset)])]
}

#' @noRd
sl_dst_design <- function(data, weeks) {
  changes <- as.Date(unlist(lapply(unique(data$year), sl_dst_dates)),
    origin = "1970-01-01"
  )
  distance <- outer(as.numeric(data$local_date), as.numeric(changes), "-")
  nearest <- apply(abs(distance), 1, which.min)
  data$days_from_transition <- distance[cbind(seq_len(nrow(data)), nearest)]
  data$transition <- factor(changes[nearest])
  data[abs(data$days_from_transition) <= weeks * 7, ]
}
