# Load the bundled real archive sample

Load the bundled real archive sample

## Usage

``` r
sl_sample()
```

## Value

An `sl_records` tibble for the documented sample forces and months.

## See also

[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_contract()`](https://blackthrive.github.io/searchlight/reference/sl_contract.md)

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
[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
x <- sl_sample()
table(x$force_id, x$month)
#>                 
#>                  2026-05 2026-06 2026-07
#>   west-yorkshire    1659    1466    1532
```
