# Census ethnicity by age and sex

Uses RM032 (NM_2132_1), available at Census 2021 small areas. Five
published age bands are combined to under 25, 25-34 and 35+, the common
partition with police age bands. Census sex and police-recorded gender
are different measurements; any analysis using them must state this
assumption. Unsupported geography returns NULL and a message. No age-sex
cross-tabulation is imputed from marginal totals.

## Usage

``` r
sl_population_crosstab(
  geography,
  dir = sl_cache_dir(),
  classification = c("5", "19")
)
```

## Arguments

- geography:

  ONS geography codes, or an sf layer with geography_code.

- dir:

  Explicit cache directory, written only on this call.

- classification:

  Census classification, 5 or 19.

## Value

An sl_exposure tibble with age_band and sex, or NULL.

## See also

[`sl_population()`](https://blackthrive.github.io/searchlight/reference/sl_population.md),
[`sl_exposure()`](https://blackthrive.github.io/searchlight/reference/sl_exposure.md)

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
[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
p <- readRDS(system.file("extdata", "sample-crosstab.rds",
  package = "searchlight"
))
head(p)
#> # A tibble: 6 × 5
#>   geography_code ethnicity age_band sex    population
#>   <chr>          <chr>     <chr>    <chr>       <dbl>
#> 1 E02002183      Asian     25-34    Female          4
#> 2 E02002183      Asian     25-34    Male            2
#> 3 E02002183      Asian     35+      Female         22
#> 4 E02002183      Asian     35+      Male           23
#> 5 E02002183      Asian     under 25 Female          2
#> 6 E02002183      Asian     under 25 Male            5
```
