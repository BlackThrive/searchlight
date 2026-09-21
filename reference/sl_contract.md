# Inspect an ingestion contract

Contracts retain source provenance through subsetting and dplyr verbs.
The coverage and timestamp tables describe the ingested sources; `scope`
records the currently visible row count and force-months after
filtering. Filtering does not turn a submitted file into a missing
submission.

## Usage

``` r
sl_contract(x)
```

## Arguments

- x:

  Records, aggregates or a contract.

## Value

A named list of class `sl_contract`.
[`summary()`](https://rdrr.io/r/base/summary.html) returns coverage.

## See also

[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md)

Other ingest:
[`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md),
[`sl_archive_index()`](https://blackthrive.github.io/searchlight/reference/sl_archive_index.md),
[`sl_archive_snapshot()`](https://blackthrive.github.io/searchlight/reference/sl_archive_snapshot.md),
[`sl_assign_geography()`](https://blackthrive.github.io/searchlight/reference/sl_assign_geography.md),
[`sl_boundaries()`](https://blackthrive.github.io/searchlight/reference/sl_boundaries.md),
[`sl_cache_clear()`](https://blackthrive.github.io/searchlight/reference/sl_cache_clear.md),
[`sl_cache_dir()`](https://blackthrive.github.io/searchlight/reference/sl_cache_dir.md),
[`sl_exposure()`](https://blackthrive.github.io/searchlight/reference/sl_exposure.md),
[`sl_list_versions()`](https://blackthrive.github.io/searchlight/reference/sl_list_versions.md),
[`sl_population()`](https://blackthrive.github.io/searchlight/reference/sl_population.md),
[`sl_population_crosstab()`](https://blackthrive.github.io/searchlight/reference/sl_population_crosstab.md),
[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
sl_contract(sl_sample())
#> 
#> ── searchlight ingestion contract ──
#> 
#> Source: data.police.uk archive
#> Snapshots: 1; selected versions: 3
#> Ethnicity: self-defined (PACE-2023/archive-labels-2026-09-16)
#> Audited force-months: 6
```
