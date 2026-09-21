# Construct an explicit exposure table

Population is an exposure. Unknown ethnicity has no Census population
denominator and must have NA population. Additional age_band and sex
columns identify disjoint strata. Counts may exceed exposure.

## Usage

``` r
sl_exposure(
  data,
  geography,
  classification = c("5", "19"),
  source = "user_supplied"
)
```

## Arguments

- data:

  A data frame with geography_code, ethnicity and population.

- geography:

  Geography type and vintage, for example msoa21.

- classification:

  Self-defined classification, 5 or 19.

- source:

  Description of a user-supplied exposure.

## Value

A tibble with class sl_exposure and an exposure contract.

## See also

[`sl_population()`](https://blackthrive.github.io/searchlight/reference/sl_population.md),
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
[`sl_list_versions()`](https://blackthrive.github.io/searchlight/reference/sl_list_versions.md),
[`sl_population()`](https://blackthrive.github.io/searchlight/reference/sl_population.md),
[`sl_population_crosstab()`](https://blackthrive.github.io/searchlight/reference/sl_population_crosstab.md),
[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md),
[`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)

## Examples

``` r
sl_exposure(data.frame(
  geography_code = "area1", ethnicity = "White",
  population = 1000
), geography = "example")
#> # A tibble: 1 × 3
#>   geography_code ethnicity population
#>   <chr>          <chr>          <dbl>
#> 1 area1          White           1000
```
