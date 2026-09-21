# Compare compatible population denominator scenarios

Exposure tables must have identical geography/classification and cell
keys. Each sampling interval is conditional on its exposure scenario;
the range of point estimates across scenarios is reported separately.

## Usage

``` r
sl_denominator_scenarios(
  counts,
  exposures,
  reference = "White",
  comparison = "Black"
)
```

## Arguments

- counts:

  Contract-bearing event counts.

- exposures:

  Named list of sl_exposure tables.

- reference, comparison:

  Groups to compare.

## Value

An sl_sensitivity tibble with scenario ratios and assumption ranges.

## See also

[`sl_exposure()`](https://blackthrive.github.io/searchlight/reference/sl_exposure.md),
[`sl_missing_ethnicity_bounds()`](https://blackthrive.github.io/searchlight/reference/sl_missing_ethnicity_bounds.md)

Other sensitivity:
[`sl_missing_ethnicity_bounds()`](https://blackthrive.github.io/searchlight/reference/sl_missing_ethnicity_bounds.md),
[`sl_ranking_stability()`](https://blackthrive.github.io/searchlight/reference/sl_ranking_stability.md),
[`sl_standardise()`](https://blackthrive.github.io/searchlight/reference/sl_standardise.md)

## Examples

``` r
p <- readRDS(system.file("extdata", "sample-population.rds",
  package = "searchlight"
))$msoa21
c <- readRDS(system.file("extdata", "example-counts.rds",
  package = "searchlight"
))
head(sl_denominator_scenarios(c, list(resident = p)))
#> sampling uncertainty: not evaluated
#> conf_low/conf_high are conditional on each exposure scenario
#> assumption range: E02002237 [0, 0]; E02002454 [0.201, 0.201]; E02006875 [0.281,
#> 0.281]; ... see table for remaining areas
#> lower_bound/upper_bound span scenario point estimates only
#> # A tibble: 4 × 21
#>   force_id       geography_code reference comparison ratio conf_low conf_high
#>   <chr>          <chr>          <chr>     <chr>      <dbl>    <dbl>     <dbl>
#> 1 west-yorkshire E02002237      White     Black      0      0           7.45 
#> 2 west-yorkshire E02002454      White     Black      0.201  0.00502     1.16 
#> 3 west-yorkshire E02006875      White     Black      0.281  0.0574      0.833
#> 4 west-yorkshire E02006948      White     Black      0.147  0.0391      0.390
#> # ℹ 14 more variables: conf_level <dbl>, method <chr>, dispersion <dbl>,
#> #   n_reference <int>, n_comparison <int>, exposure_reference <dbl>,
#> #   exposure_comparison <dbl>, estimable <lgl>, model <list>,
#> #   excluded_pair_events <int>, unknown_events <int>, scenario <chr>,
#> #   lower_bound <dbl>, upper_bound <dbl>
```
