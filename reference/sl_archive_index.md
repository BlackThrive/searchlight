# List available bulk archive snapshots

Parses advertised month ranges and publisher MD5 checksums. The complete
rolling snapshot can contain several years. Results are cached only
after this function is called. Source failures return `NULL` with a
message.

## Usage

``` r
sl_archive_index(
  dir = sl_cache_dir(),
  refresh = FALSE,
  url = "https://data.police.uk/data/archive/"
)
```

## Arguments

- dir:

  Cache directory.

- refresh:

  Refresh the cached index.

- url:

  Archive listing URL, normally the official source.

## Value

A tibble with archive name, snapshot month, coverage range, URL and MD5,
or `NULL` if unavailable.

## See also

[`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md)

Other ingest:
[`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md),
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
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
index <- readRDS(system.file("extdata", "archive-index.rds",
  package = "searchlight"
))
index[, c("archive_file", "month_start", "month_end")]
#> # A tibble: 3 × 3
#>   archive_file month_start month_end
#>   <chr>        <chr>       <chr>    
#> 1 2026-07.zip  2023-08     2026-07  
#> 2 2026-06.zip  2023-07     2026-06  
#> 3 2026-05.zip  2023-06     2026-05  
```
