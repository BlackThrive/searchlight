# Census 2021 ethnicity populations

Fetches TS021 (NM_2041_1), with exact codes verified against returned
cells. Supply ONS codes or an sf boundary object. Current ward and LAD
boundaries must not be silently matched to Census 2021 units: unchanged
codes alone do not demonstrate unchanged boundaries. A new exposure
source must be supplied for changed units. Census disclosure control may
cause small inconsistencies between separately published tables. Unknown
is retained with NA exposure.

## Usage

``` r
sl_population(geography, classification = c("5", "19"), dir = sl_cache_dir())
```

## Arguments

- geography:

  ONS geography codes, or an sf layer with geography_code.

- classification:

  Census classification, 5 or 19.

- dir:

  Explicit cache directory, written only on this call.

## Value

An sl_exposure tibble, or NULL with a message if unavailable.

## See also

[`sl_exposure()`](https://blackthrive.github.io/searchlight/reference/sl_exposure.md),
[`sl_population_crosstab()`](https://blackthrive.github.io/searchlight/reference/sl_population_crosstab.md)

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
[`sl_population_crosstab()`](https://blackthrive.github.io/searchlight/reference/sl_population_crosstab.md),
[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
p <- readRDS(system.file("extdata", "sample-population.rds",
  package = "searchlight"
))
head(p$msoa21)
#> # A tibble: 6 × 3
#>   geography_code ethnicity population
#>   <chr>          <chr>          <dbl>
#> 1 E02002183      Asian             57
#> 2 E02002183      Black             17
#> 3 E02002183      Mixed             65
#> 4 E02002183      Other              5
#> 5 E02002183      White           5558
#> 6 E02002184      Asian            219
```
