# Cross-check annual totals against the Home Office

Years end on 31 March. Ratios are withheld unless twelve force-months
are submitted or refreshed and the current records contain every
selected row. The benchmark is not an equality guarantee: scope of
powers, event versus person/vehicle reporting, publication cut-offs and
revisions can differ.

## Usage

``` r
sl_benchmark(records, ppap_table = NULL, tolerance = 0.1)
```

## Arguments

- records:

  Contract-bearing records.

- ppap_table:

  Table with force_id, year_end and published_total. Default is the
  bundled Home Office table SS_20, year ending March 2025.

- tolerance:

  Flag absolute proportional differences exceeding this value.

## Value

A tibble with observed/published counts, coverage, ratio and flags.

## See also

[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md)

Other audit:
[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md),
[`sl_coverage_compare()`](https://blackthrive.github.io/searchlight/reference/sl_coverage_compare.md),
[`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md),
[`sl_quality()`](https://blackthrive.github.io/searchlight/reference/sl_quality.md),
[`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md)

## Examples

``` r
ppap <- utils::read.csv(system.file("extdata", "ppap-totals.csv",
  package = "searchlight"
))
sl_benchmark(sl_sample(), ppap)
#>         force_id  pfa_code year_end published_total
#> 1 west-yorkshire E23000010     2025           18039
#> 2    dyfed-powys W15000004     2025            3696
#>                             scope  retrieved
#> 1 All relevant legislation; SS_20 2026-09-16
#> 2 All relevant legislation; SS_20 2026-09-16
#>                                                                                                     source
#> 1 https://www.gov.uk/government/statistics/stop-and-search-arrests-and-mental-health-detentions-march-2025
#> 2 https://www.gov.uk/government/statistics/stop-and-search-arrests-and-mental-health-detentions-march-2025
#>   observed_total submitted_months complete ratio beyond_tolerance
#> 1             NA                0    FALSE    NA               NA
#> 2             NA                0    FALSE    NA               NA
#>                                                  reason
#> 1 incomplete year, suspect coverage or filtered records
#> 2 incomplete year, suspect coverage or filtered records
```
