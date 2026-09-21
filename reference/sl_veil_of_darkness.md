# Diagnose ethnicity composition in daylight and darkness

Excludes every force-month that fails or lacks the contract's
time-quality screen, retaining an explicit exclusion table. Annual
evening clock-time bounds use each distinct location and year. Civil
darkness begins at dusk; ambiguous sunset-to-dusk observations are
excluded. Times and clock changes use Europe/London, including British
summer time. The logistic comparison controls clock time (natural
spline), weekday, month and force where these vary. The DST option
further restricts to weeks around both clock changes and adds transition
and running-day controls; it is a local darkness comparison. The method
was developed for vehicle stops. Transfer to pedestrian searches
requires assumptions about visibility, activity, deployment and
selection.

## Usage

``` r
sl_veil_of_darkness(
  records,
  boundaries = NULL,
  twilight = c("civil", "sunset"),
  window = "intertwilight",
  design = c("intertwilight", "dst"),
  reference = "White",
  comparison = "Black",
  dst_weeks = 3,
  conf_level = 0.95
)
```

## Arguments

- records:

  Contract-bearing search records.

- boundaries:

  Optional sf study region; restrict published points to it. Missing
  locations are never replaced by centroids.

- twilight:

  Civil twilight end or sunset definition of darkness.

- window:

  Currently only intertwilight, the annual evening overlap window.

- design:

  Annual intertwilight or local DST-window comparison.

- reference, comparison:

  Known self-defined ethnicity groups.

- dst_weeks:

  Weeks on either side of each clock change for the DST design.

- conf_level:

  Logistic Wald confidence level.

## Value

An sl_veil tibble with an odds ratio, interval and fit status.
Attributes steps, excluded_force_months, assumptions, data and model
retain the full design audit. A gated or unidentifiable sample has an
undefined ratio.

## See also

[`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md),
[`sl_hit_rates()`](https://blackthrive.github.io/searchlight/reference/sl_hit_rates.md)

Other inference:
[`sl_count_model()`](https://blackthrive.github.io/searchlight/reference/sl_count_model.md),
[`sl_hit_rates()`](https://blackthrive.github.io/searchlight/reference/sl_hit_rates.md),
[`sl_simulate()`](https://blackthrive.github.io/searchlight/reference/sl_simulate.md),
[`sl_spatial_disparity()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_disparity.md),
[`sl_spatial_map()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_map.md)

## Examples

``` r
# Date-only records are explicitly refused by the time-quality screen.
x <- sl_sample()[1:10, ]
day <- as.Date(x$date, tz = "Europe/London")
x$date <- as.POSIXct(paste(day, "00:00:00"), tz = "Europe/London")
x$date_raw <- format(x$date, "%Y-%m-%dT%H:%M:%S%z")
attr(x, "contract")$timestamps <- sl_timestamp_quality(x)
sl_veil_of_darkness(x)
#> Excluded 1 unreliable force-month(s).
#> # A tibble: 1 × 14
#>   term  odds_ratio conf_low conf_high log_std_error     n status  model_warnings
#>   <chr>      <dbl>    <dbl>     <dbl>         <dbl> <int> <chr>   <chr>         
#> 1 dark          NA       NA        NA            NA     0 insuff… ""            
#> # ℹ 6 more variables: reference <chr>, comparison <chr>, design <chr>,
#> #   twilight <chr>, dark_stops <int>, daylight_stops <int>
```
