# Diagnose timestamp completeness and midnight heaping

Reports both London-clock midnight and midnight in the source string.
Some date-only summer records carry a UTC offset, so checking London
midnight alone would miss them. Reliability requires both shares below
threshold and no missing timestamps. This is a screening diagnostic, not
proof that all supplied times are accurate. Empty and absent
force-months are not reliable.

## Usage

``` r
sl_timestamp_quality(records, threshold = 0.05)
```

## Arguments

- records:

  Contract-bearing records.

- threshold:

  Maximum permitted midnight share, default 0.05.

## Value

A tibble with force-month diagnostics and within-force share range.

## See also

[`sl_quality()`](https://blackthrive.github.io/searchlight/reference/sl_quality.md),
[`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md)

Other audit:
[`sl_benchmark()`](https://blackthrive.github.io/searchlight/reference/sl_benchmark.md),
[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md),
[`sl_coverage_compare()`](https://blackthrive.github.io/searchlight/reference/sl_coverage_compare.md),
[`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md),
[`sl_quality()`](https://blackthrive.github.io/searchlight/reference/sl_quality.md)

## Examples

``` r
sl_timestamp_quality(sl_sample())
#> # A tibble: 6 × 10
#>   force_id       month   n_records midnight_share missing_time_share
#>   <chr>          <chr>       <int>          <dbl>              <dbl>
#> 1 dyfed-powys    2026-05        NA       NA                       NA
#> 2 dyfed-powys    2026-06        NA       NA                       NA
#> 3 dyfed-powys    2026-07        NA       NA                       NA
#> 4 west-yorkshire 2026-05      1659        0.0102                   0
#> 5 west-yorkshire 2026-06      1466        0.00750                  0
#> 6 west-yorkshire 2026-07      1532        0.0111                   0
#> # ℹ 5 more variables: source_midnight_share <dbl>, gating_midnight_share <dbl>,
#> #   london_month_mismatch_share <dbl>, time_reliable <lgl>,
#> #   force_midnight_range <dbl>
```
