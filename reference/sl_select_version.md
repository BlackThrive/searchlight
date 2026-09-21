# Select one complete version per force-month

Never deduplicates event rows. Ties are resolved by snapshot month and
archive name. `max_rows` chooses the newest version among equal row
counts. Differences greater than 1% of the smallest count are reported
(zero to positive is infinite).

## Usage

``` r
sl_select_version(
  versions,
  rule = c("latest", "earliest", "max_rows", "manual"),
  manual = NULL
)
```

## Arguments

- versions:

  Output from
  [`sl_list_versions()`](https://blackthrive.github.io/searchlight/reference/sl_list_versions.md).

- rule:

  Version selection rule.

- manual:

  For the manual rule, a tibble with `force_id`, `month`,
  `archive_file`, containing exactly one choice per force-month.

## Value

Selected versions with list-column alternatives and a `differences`
attribute. Each row carries the selection rule.

## See also

[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md)

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
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md)

## Examples

``` r
d <- system.file("extdata", "sample", package = "searchlight")
v <- sl_list_versions(d)
sl_select_version(v)
#> # A tibble: 3 × 13
#>   force_id       month archive_file snapshot_month csv_path csv_sha256 n_records
#>   <chr>          <chr> <chr>        <chr>          <chr>    <chr>          <int>
#> 1 west-yorkshire 2026… 2026-07.zip  2026-07        2026-05… aa07c0933…      1659
#> 2 west-yorkshire 2026… 2026-07.zip  2026-07        2026-06… a302977a9…      1466
#> 3 west-yorkshire 2026… 2026-07.zip  2026-07        2026-07… c72a1a84f…      1532
#> # ℹ 6 more variables: archive_sha256 <chr>, downloaded_at <dttm>, url <chr>,
#> #   source_csv_sha256 <chr>, alternatives <list>, selection_rule <chr>
```
