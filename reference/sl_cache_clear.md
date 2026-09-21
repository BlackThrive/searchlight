# Clear a marked searchlight cache

Only removes searchlight-managed entries in a directory bearing the
marker created by acquisition. Other user files are retained. This is
destructive.

## Usage

``` r
sl_cache_clear(dir = sl_cache_dir())
```

## Arguments

- dir:

  Cache directory.

## Value

Invisibly, paths removed.

## See also

[`sl_cache_dir()`](https://blackthrive.github.io/searchlight/reference/sl_cache_dir.md)

Other ingest:
[`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md),
[`sl_archive_index()`](https://blackthrive.github.io/searchlight/reference/sl_archive_index.md),
[`sl_archive_snapshot()`](https://blackthrive.github.io/searchlight/reference/sl_archive_snapshot.md),
[`sl_assign_geography()`](https://blackthrive.github.io/searchlight/reference/sl_assign_geography.md),
[`sl_boundaries()`](https://blackthrive.github.io/searchlight/reference/sl_boundaries.md),
[`sl_cache_dir()`](https://blackthrive.github.io/searchlight/reference/sl_cache_dir.md),
[`sl_contract()`](https://blackthrive.github.io/searchlight/reference/sl_contract.md),
[`sl_exposure()`](https://blackthrive.github.io/searchlight/reference/sl_exposure.md),
[`sl_list_versions()`](https://blackthrive.github.io/searchlight/reference/sl_list_versions.md),
[`sl_population()`](https://blackthrive.github.io/searchlight/reference/sl_population.md),
[`sl_population_crosstab()`](https://blackthrive.github.io/searchlight/reference/sl_population_crosstab.md),
[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
d <- tempfile()
dir.create(d)
file.create(file.path(d, ".searchlight-cache"))
#> [1] TRUE
sl_cache_clear(d)
unlink(d, recursive = TRUE)
```
