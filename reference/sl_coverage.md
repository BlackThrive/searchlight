# Audit submission coverage on a full force-month grid

Counts come from the immutable selected files, including after filtering
records. A submitted zero-row CSV is zero; an absent CSV is NA.
Refreshes describe differing version counts. Partial suspicion takes
precedence over refreshes, and uses preceding calendar months (at most
twelve), not twelve observed files. A changelog issue does not create a
nonexistent submission.

## Usage

``` r
sl_coverage(
  records,
  forces = NULL,
  months = NULL,
  changelog = NULL,
  partial_threshold = 0.2
)
```

## Arguments

- records:

  Contract-bearing records.

- forces:

  Force IDs; default is the contract's requested forces.

- months:

  Months; default is the contract's requested months.

- changelog:

  Table with force_id, month, note and optional issue flag. Default uses
  the bundled, dated changelog extract.

- partial_threshold:

  Fraction of trailing median, default 0.2.

## Value

An sl_coverage tibble with contract; plot gives a coverage heatmap.

## See also

[`sl_quality()`](https://blackthrive.github.io/searchlight/reference/sl_quality.md),
[`sl_coverage_compare()`](https://blackthrive.github.io/searchlight/reference/sl_coverage_compare.md),
[`sl_benchmark()`](https://blackthrive.github.io/searchlight/reference/sl_benchmark.md)

Other audit:
[`sl_benchmark()`](https://blackthrive.github.io/searchlight/reference/sl_benchmark.md),
[`sl_coverage_compare()`](https://blackthrive.github.io/searchlight/reference/sl_coverage_compare.md),
[`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md),
[`sl_quality()`](https://blackthrive.github.io/searchlight/reference/sl_quality.md),
[`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md)

## Examples

``` r
audit <- sl_coverage(sl_sample())
audit
#> # A tibble: 6 × 6
#>   force_id       month   n_records status    trailing_median changelog_note     
#>   <chr>          <chr>       <int> <chr>               <dbl> <chr>              
#> 1 dyfed-powys    2026-05        NA missing               NA  Dyfed-Powys Police…
#> 2 dyfed-powys    2026-06        NA missing               NA  Dyfed-Powys Police…
#> 3 dyfed-powys    2026-07        NA missing               NA  Dyfed-Powys Police…
#> 4 west-yorkshire 2026-05      1659 submitted             NA  NA                 
#> 5 west-yorkshire 2026-06      1466 submitted           1659  NA                 
#> 6 west-yorkshire 2026-07      1532 submitted           1562. NA                 
# plot(audit) displays the submission heatmap.
```
