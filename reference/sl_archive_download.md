# Download and verify the necessary archive snapshots

Selects the newest available snapshots that cover the requested months.
Forces are recorded as extraction filters; the source only offers full
ZIPs. Checks publisher MD5 before recording local SHA-256. Existing
files must match both the publisher and any recorded SHA-256; corrupt
files are never replaced silently. The manifest and ZIPs are written to
`dir`.

## Usage

``` r
sl_archive_download(months, forces = NULL, dir = sl_cache_dir(), index = NULL)
```

## Arguments

- months:

  Character vector of YYYY-MM months.

- forces:

  Force identifiers, or `NULL` for all forces.

- dir:

  Cache directory.

- index:

  Optional previously retrieved archive index.

## Value

Manifest tibble, or `NULL` when a resource is unavailable.

## See also

[`sl_archive_snapshot()`](https://blackthrive.github.io/searchlight/reference/sl_archive_snapshot.md),
[`sl_list_versions()`](https://blackthrive.github.io/searchlight/reference/sl_list_versions.md)

Other ingest:
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
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
index <- readRDS(system.file("extdata", "archive-index.rds",
  package = "searchlight"
))
index$archive_file[1]
#> [1] "2026-07.zip"
```
