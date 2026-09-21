# Diagnose anonymised location quality

Snap-point concentration is the share at the most common reported
coordinate within an LSOA, among records with usable coordinates in that
LSOA. It is not the concentration at true incident locations. Missing
LSOA assignments remain a separate group. Per-geography boundary
diagnostics remain in the contract.

## Usage

``` r
sl_location_quality(records)
```

## Arguments

- records:

  Contract-bearing records, optionally with assigned LSOAs.

## Value

A force-month-LSOA tibble with missingness, concentration and boundary
sensitivity, carrying the contract.

## See also

[`sl_assign_geography()`](https://blackthrive.github.io/searchlight/reference/sl_assign_geography.md),
[`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md)

Other audit:
[`sl_benchmark()`](https://blackthrive.github.io/searchlight/reference/sl_benchmark.md),
[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md),
[`sl_coverage_compare()`](https://blackthrive.github.io/searchlight/reference/sl_coverage_compare.md),
[`sl_quality()`](https://blackthrive.github.io/searchlight/reference/sl_quality.md),
[`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md)

## Examples

``` r
sl_location_quality(sl_sample()[1:100, ])
#> # A tibble: 59 × 7
#>    force_id month lsoa21 n_records missing_coordinate_s…¹ snap_point_concentra…²
#>    <chr>    <chr> <chr>      <int>                  <dbl>                  <dbl>
#>  1 west-yo… 2026… E0101…         1                      0                      1
#>  2 west-yo… 2026… E0101…         2                      0                      1
#>  3 west-yo… 2026… E0101…         1                      0                      1
#>  4 west-yo… 2026… E0101…         1                      0                      1
#>  5 west-yo… 2026… E0101…         1                      0                      1
#>  6 west-yo… 2026… E0101…         2                      0                      1
#>  7 west-yo… 2026… E0101…         2                      0                      1
#>  8 west-yo… 2026… E0101…         2                      0                      1
#>  9 west-yo… 2026… E0101…         1                      0                      1
#> 10 west-yo… 2026… E0101…         1                      0                      1
#> # ℹ 49 more rows
#> # ℹ abbreviated names: ¹​missing_coordinate_share, ²​snap_point_concentration
#> # ℹ 1 more variable: boundary_sensitive_share <dbl>
```
