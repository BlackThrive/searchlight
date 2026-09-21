# Compare coverage patterns across two periods

Periods are explicit month vectors sorted chronologically. Comparability
means equal length, matching submitted positions, at least one submitted
position, and no partial suspicion. Identical missing positions are
listed but allow comparison of the same observed subset. This tests
coverage only, not seasonality, reporting practice or population
comparability.

## Usage

``` r
sl_coverage_compare(coverage, period_a, period_b)
```

## Arguments

- coverage:

  Output of sl_coverage.

- period_a, period_b:

  Month vectors for comparison.

## Value

A tibble with comparable, submitted positions, and a list of gaps.

## See also

[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md)

Other audit:
[`sl_benchmark()`](https://blackthrive.github.io/searchlight/reference/sl_benchmark.md),
[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md),
[`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md),
[`sl_quality()`](https://blackthrive.github.io/searchlight/reference/sl_quality.md),
[`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md)

## Examples

``` r
sl_coverage_compare(sl_coverage(sl_sample()), "2026-05", "2026-06")
#> # A tibble: 2 × 5
#>   force_id       comparable submitted_a submitted_b breaking_months 
#>   <chr>          <lgl>      <list>      <list>      <list>          
#> 1 dyfed-powys    FALSE      <int [0]>   <int [0]>   <tibble [2 × 5]>
#> 2 west-yorkshire TRUE       <int [1]>   <int [1]>   <tibble [0 × 5]>
```
