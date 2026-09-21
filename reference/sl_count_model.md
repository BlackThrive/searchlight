# Fit count models with population-time exposure

Models recorded events, never unique people or a population-minus-stops
cell. A population offset is multiplied by months_submitted/12 when
available. Other offset columns must already represent exposure over the
observed period. Unknown ethnicity and rows without positive exposure
are reported as exclusions. Moran's I uses mean Pearson residuals per
area and is exploratory after fitting. The exponentiated intercept is a
baseline rate per exposure unit; other exponentiated coefficients are
multiplicative rate effects. Confidence bounds are reported on this
exponentiated scale.

## Usage

``` r
sl_count_model(
  counts,
  formula,
  family = c("poisson", "negbin"),
  offset = "population",
  random = NULL,
  boundaries = NULL,
  conf_level = 0.95
)
```

## Arguments

- counts:

  Counts with a contract and exposure column, usually sl_rates.

- formula:

  A formula with response n and desired fixed predictors.

- family:

  Poisson or negative binomial.

- offset:

  Name of the population or population-time exposure column.

- random:

  Optional one-sided lme4 formula, for example ~ (1 \| force_id).

- boundaries:

  Optional sf polygons keyed by geography_code for residuals.

- conf_level:

  Wald confidence level.

## Value

A tidy sl_count_model coefficient table with model, diagnostics and
excluded row/event counts in attributes, carrying the ingestion
contract.

## See also

[`sl_rates()`](https://blackthrive.github.io/searchlight/reference/sl_rates.md),
[`sl_spatial_disparity()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_disparity.md)

Other inference:
[`sl_hit_rates()`](https://blackthrive.github.io/searchlight/reference/sl_hit_rates.md),
[`sl_simulate()`](https://blackthrive.github.io/searchlight/reference/sl_simulate.md),
[`sl_spatial_disparity()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_disparity.md),
[`sl_spatial_map()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_map.md),
[`sl_veil_of_darkness()`](https://blackthrive.github.io/searchlight/reference/sl_veil_of_darkness.md)

## Examples

``` r
r <- readRDS(system.file("extdata", "example-rates.rds",
  package = "searchlight"
))
r <- r[r$ethnicity %in% c("White", "Black"), ]
sl_count_model(r, n ~ ethnicity)
#> # A tibble: 2 × 8
#>   term     estimate std_error statistic  p_value exp_estimate conf_low conf_high
#>   <chr>       <dbl>     <dbl>     <dbl>    <dbl>        <dbl>    <dbl>     <dbl>
#> 1 (Interc…    -3.81     0.354    -10.8  4.93e-27       0.0222   0.0111    0.0444
#> 2 ethnici…     1.24     0.357      3.47 5.27e- 4       3.45     1.71      6.95  
# Supply matching boundaries to request the residual Moran diagnostic.
```
