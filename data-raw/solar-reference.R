# Developer-only: freeze outputs before replacing the former dependency.
# This script is excluded from the package and is never run during checks.
# Run against release revision 03279ea (0.1.0), before the two calls are replaced.
.libPaths(c("data-raw/work/solar-replacement/reference-library", .libPaths()))
stopifnot(as.character(utils::packageVersion("suncalc")) == "0.5.3")
Sys.setenv(NO_INTERNET_TEST = "true", NOT_CRAN = "false", VROOM_THREADS = "2")
pkgload::load_all(quiet = TRUE)
stopifnot(as.character(utils::packageVersion("searchlight")) == "0.1.0")
source("tests/testthat/helper-veil.R")
out <- "tests/testthat/fixtures/solar-reference.rds"
stopifnot(!file.exists(out))
locations <- data.frame(
  place = c("London", "Leeds", "Cardiff", "Penzance", "Berwick", "Lowestoft"),
  lat = c(51.5, 53.8, 51.48, 50.12, 55.77, 52.48),
  lon = c(-0.1, -1.5, -3.18, -5.54, -2.0, 1.75)
)
grid <- do.call(rbind, lapply(c(2014L, 2024L, 2026L, 2030L), function(year) {
  days <- seq(as.Date(paste0(year, "-01-01")),
    as.Date(paste0(year, "-12-31")),
    by = "day"
  )
  do.call(rbind, lapply(seq_len(nrow(locations)), function(i) {
    data.frame(date = days, lat = locations$lat[i], lon = locations$lon[i])
  }))
}))
solar <- suncalc::getSunlightTimes(
  data = grid, keep = c("sunset", "dusk"), tz = "Europe/London"
)
solar$sunset <- as.numeric(solar$sunset)
solar$dusk <- as.numeric(solar$dusk)
bound_locations <- data.frame(
  latitude = c(51.5, 53.8, 51.5), longitude = c(-0.1, -1.5, -0.1),
  year = c(2024L, 2026L, 2026L), location = c(9L, 3L, 7L)
)
bounds <- lapply(c("sunset", "dusk"), function(name) {
  sl_annual_sun_bounds <- getFromNamespace("sl_annual_sun_bounds", "searchlight")
  sl_annual_sun_bounds(bound_locations, name)
})
names(bounds) <- c("sunset", "dusk")
x <- fixture_veil()
models <- lapply(c("intertwilight", "dst"), function(design) {
  lapply(c("civil", "sunset"), function(twilight) {
    fit <- sl_veil_of_darkness(x, design = design, twilight = twilight)
    data <- attr(fit, "data")
    list(
      summary = as.data.frame(fit), steps = attr(fit, "steps"),
      data = as.data.frame(data[c(
        "date", "latitude", "longitude", "dark",
        "earliest", "latest", "sunset", "dusk"
      )])
    )
  })
})
dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
saveRDS(
  list(
    source = "suncalc 0.5.3", solar = solar,
    locations = bound_locations, bounds = bounds, models = models
  ),
  out,
  version = 2, compress = "xz"
)
cat("Saved", nrow(solar), "location-days and four complete analysis baselines.\n")
print(head(solar, 2), digits = 16)
