# Estimate an event stop-rate ratio with exposure offsets

Fits n ~ ethnicity with log(population-time) offset within each area and
other grouping stratum, pooling submitted months. Poisson intervals are
exact conditional intervals for two event counts; zero counts are
supported without adding pseudocounts. Quasi-Poisson and negative
binomial require replicated cells and use model-based log intervals.
Dispersion is Pearson chi-square divided by residual degrees of freedom.
This is not a person-level risk ratio.

## Usage

``` r
sl_rate_ratio(
  rates,
  reference = "White",
  comparison = "Black",
  method = c("poisson", "quasipoisson", "negbin"),
  conf_level = 0.95
)
```

## Arguments

- rates:

  Output from sl_rates.

- reference, comparison:

  Self-defined ethnicity groups.

- method:

  Count model family.

- conf_level:

  Sampling confidence level.

## Value

An sl_rate_ratio tibble with sampling intervals, dispersion, counts,
exposures and fitted model list column, carrying the ingestion contract.

## See also

[`sl_rates()`](https://blackthrive.github.io/searchlight/reference/sl_rates.md),
[`sl_missing_ethnicity_bounds()`](https://blackthrive.github.io/searchlight/reference/sl_missing_ethnicity_bounds.md)

Other rates:
[`sl_counts()`](https://blackthrive.github.io/searchlight/reference/sl_counts.md),
[`sl_rates()`](https://blackthrive.github.io/searchlight/reference/sl_rates.md)

## Examples

``` r
r <- readRDS(system.file("extdata", "example-rates.rds",
  package = "searchlight"
))
head(sl_rate_ratio(r))
#> # A tibble: 4 × 18
#>   force_id       geography_code reference comparison ratio conf_low conf_high
#>   <chr>          <chr>          <chr>     <chr>      <dbl>    <dbl>     <dbl>
#> 1 west-yorkshire E02002237      White     Black      0      0           7.45 
#> 2 west-yorkshire E02002454      White     Black      0.201  0.00502     1.16 
#> 3 west-yorkshire E02006875      White     Black      0.281  0.0574      0.833
#> 4 west-yorkshire E02006948      White     Black      0.147  0.0391      0.390
#> # ℹ 11 more variables: conf_level <dbl>, method <chr>, dispersion <dbl>,
#> #   n_reference <int>, n_comparison <int>, exposure_reference <dbl>,
#> #   exposure_comparison <dbl>, estimable <lgl>, model <list>,
#> #   excluded_pair_events <int>, unknown_events <int>
```
