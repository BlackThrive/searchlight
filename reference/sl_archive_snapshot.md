# Extract immutable stop and search CSV snapshots

Other archive contents are not extracted. Retains source ZIPs and raw
CSV bytes. A manifest records archive and CSV SHA-256, row count and
original member path. ZIP traversal paths are refused. Previously
extracted CSVs are hash-checked.

## Usage

``` r
sl_archive_snapshot(dir = sl_cache_dir(), months = NULL, forces = NULL)
```

## Arguments

- dir:

  Cache containing archive ZIPs and optionally a download manifest.

- months:

  Optional YYYY-MM filter; defaults to the download request.

- forces:

  Optional force filter; defaults to the download request.

## Value

A tibble of CSV versions. Writes snapshots and their manifest in `dir`.

## See also

[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md),
[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md)

Other ingest:
[`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md),
[`sl_archive_index()`](https://blackthrive.github.io/searchlight/reference/sl_archive_index.md),
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
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
sl_list_versions(system.file("extdata", "sample", package = "searchlight"))
#> # A tibble: 3 × 11
#>   force_id       month archive_file snapshot_month csv_path csv_sha256 n_records
#>   <chr>          <chr> <chr>        <chr>          <chr>    <chr>          <int>
#> 1 west-yorkshire 2026… 2026-07.zip  2026-07        2026-05… aa07c0933…      1659
#> 2 west-yorkshire 2026… 2026-07.zip  2026-07        2026-06… a302977a9…      1466
#> 3 west-yorkshire 2026… 2026-07.zip  2026-07        2026-07… c72a1a84f…      1532
#> # ℹ 4 more variables: archive_sha256 <chr>, downloaded_at <dttm>, url <chr>,
#> #   source_csv_sha256 <chr>
```
