# Attach submission, timestamp and location diagnostics

Pass population to complete the population metadata in the records
contract; population counts remain a separate exposure table.
Diagnostics describe the current records; coverage continues to describe
the original source files.

## Usage

``` r
sl_quality(records, population = NULL, threshold = 0.05, changelog = NULL)
```

## Arguments

- records:

  Contract-bearing records.

- population:

  Optional sl_exposure table.

- threshold:

  Midnight-share threshold.

- changelog:

  Optional changelog table passed to sl_coverage.

## Value

Records with an updated contract and attached quality tables.

## See also

[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md),
[`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md),
[`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md)

Other audit:
[`sl_benchmark()`](https://blackthrive.github.io/searchlight/reference/sl_benchmark.md),
[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md),
[`sl_coverage_compare()`](https://blackthrive.github.io/searchlight/reference/sl_coverage_compare.md),
[`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md),
[`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md)

## Examples

``` r
records <- sl_quality(sl_sample()[1:100, ])
sl_contract(records)$timestamps
#> # A tibble: 6 × 10
#>   force_id       month   n_records midnight_share missing_time_share
#>   <chr>          <chr>       <int>          <dbl>              <dbl>
#> 1 dyfed-powys    2026-05        NA             NA                 NA
#> 2 dyfed-powys    2026-06        NA             NA                 NA
#> 3 dyfed-powys    2026-07        NA             NA                 NA
#> 4 west-yorkshire 2026-05       100              0                  0
#> 5 west-yorkshire 2026-06        NA             NA                 NA
#> 6 west-yorkshire 2026-07        NA             NA                 NA
#> # ℹ 5 more variables: source_midnight_share <dbl>, gating_midnight_share <dbl>,
#> #   london_month_mismatch_share <dbl>, time_reliable <lgl>,
#> #   force_midnight_range <dbl>
```
