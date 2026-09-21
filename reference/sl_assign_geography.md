# Assign anonymised points to local geographies

Uses British National Grid (EPSG:27700). Missing or invalid coordinates
are retained with NA assignments. On shared polygon edges, ties are
resolved by code and flagged ambiguous. Boundary distances describe
anonymised snap points, not the unknown true locations; resulting error
may be systematic. The boundary-sensitive share uses assigned events
with measured distances. Missing-coordinate and unassigned shares use
all supplied events.

## Usage

``` r
sl_assign_geography(
  records,
  boundaries,
  types = names(boundaries),
  threshold = 50
)
```

## Arguments

- records:

  Contract-bearing records.

- boundaries:

  A named list of sf layers, or one sf layer with metadata.

- types:

  Names of the layers to assign; defaults to supplied layers.

- threshold:

  Boundary-sensitive distance in metres.

## Value

Records with geography codes, per-layer distances and flags, and an
updated contract. No event rows are dropped or duplicated.

## See also

[`sl_boundaries()`](https://blackthrive.github.io/searchlight/reference/sl_boundaries.md),
[`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md)

Other ingest:
[`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md),
[`sl_archive_index()`](https://blackthrive.github.io/searchlight/reference/sl_archive_index.md),
[`sl_archive_snapshot()`](https://blackthrive.github.io/searchlight/reference/sl_archive_snapshot.md),
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
b <- readRDS(system.file("extdata", "sample-boundaries.rds",
  package = "searchlight"
))
x <- sl_sample()[1:3, ]
b$msoa21 <- b$msoa21[b$msoa21$geography_code %in% x$msoa21, ]
sl_assign_geography(x, b, "msoa21")
#> # A tibble: 3 × 38
#>   type    date                part_of_a_policing_o…¹ policing_operation latitude
#>   <fct>   <dttm>              <lgl>                  <chr>                 <dbl>
#> 1 Person… 2026-05-01 00:03:00 FALSE                  NA                     53.8
#> 2 Person… 2026-05-01 00:15:00 FALSE                  NA                     53.8
#> 3 Person… 2026-05-01 00:30:00 FALSE                  NA                     53.7
#> # ℹ abbreviated name: ¹​part_of_a_policing_operation
#> # ℹ 33 more variables: longitude <dbl>, gender <fct>, age_range <fct>,
#> #   self_defined_ethnicity_raw <chr>, officer_defined_ethnicity <chr>,
#> #   legislation <chr>, object_of_search <chr>, outcome <chr>,
#> #   outcome_linked_to_object_of_search <chr>,
#> #   removal_of_more_than_just_outer_clothing <chr>, date_raw <chr>,
#> #   force_id <chr>, month <chr>, ethnicity_5 <fct>, ethnicity_19 <fct>, …
```
