# Read selected immutable archive records

Validates the fixed CSV schema, checksum and row count, preserving every
event (including identical rows) and raw ethnicity strings. Timestamps
retain their supplied UTC offsets and are displayed in Europe/London.
Absent or refused ethnicity is Unknown. Missing outcome measures remain
NA, not negative outcomes. The filename defines the submission month.
Offset conversion can cross a month boundary; date_month_crossing
records this without moving the event into another source file. A
timestamp must match the filename in either its supplied clock or the
London clock.

## Usage

``` r
sl_read_records(dir = sl_cache_dir(), versions = NULL)
```

## Arguments

- dir:

  Snapshot cache directory.

- versions:

  One selected version per force-month; defaults to latest.

## Value

An `sl_records` tibble with a validated ingestion contract.

## See also

[`sl_contract()`](https://blackthrive.github.io/searchlight/reference/sl_contract.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md),
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md)

Other ingest:
[`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md),
[`sl_archive_index()`](https://blackthrive.github.io/searchlight/reference/sl_archive_index.md),
[`sl_archive_snapshot()`](https://blackthrive.github.io/searchlight/reference/sl_archive_snapshot.md),
[`sl_assign_geography()`](https://blackthrive.github.io/searchlight/reference/sl_assign_geography.md),
[`sl_boundaries()`](https://blackthrive.github.io/searchlight/reference/sl_boundaries.md),
[`sl_cache_clear()`](https://blackthrive.github.io/searchlight/reference/sl_cache_clear.md),
[`sl_cache_dir()`](https://blackthrive.github.io/searchlight/reference/sl_cache_dir.md),
[`sl_contract()`](https://blackthrive.github.io/searchlight/reference/sl_contract.md),
[`sl_exposure()`](https://blackthrive.github.io/searchlight/reference/sl_exposure.md),
[`sl_list_versions()`](https://blackthrive.github.io/searchlight/reference/sl_list_versions.md),
[`sl_population()`](https://blackthrive.github.io/searchlight/reference/sl_population.md),
[`sl_population_crosstab()`](https://blackthrive.github.io/searchlight/reference/sl_population_crosstab.md),
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
d <- system.file("extdata", "sample", package = "searchlight")
v <- sl_select_version(sl_list_versions(d))
records <- sl_read_records(d, v[1, ])
summary(sl_contract(records))
#> # A tibble: 6 × 5
#>   force_id       month   status    n_records changelog_note
#>   <chr>          <chr>   <chr>         <int> <chr>         
#> 1 west-yorkshire 2026-05 submitted      1659 NA            
#> 2 dyfed-powys    2026-05 missing          NA NA            
#> 3 west-yorkshire 2026-06 missing          NA NA            
#> 4 dyfed-powys    2026-06 missing          NA NA            
#> 5 west-yorkshire 2026-07 missing          NA NA            
#> 6 dyfed-powys    2026-07 missing          NA NA            
```
