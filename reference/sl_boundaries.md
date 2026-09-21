# Fetch a versioned ONS boundary layer

Uses a verified catalogue; latest means the latest verified vintage in
the installed catalogue, not an unrecorded live change. Boundaries are
BGC (20 m generalised, coast clipped). Region polygons cover England.
Census hierarchy and current administrative lookups are attached with
separate vintages.

## Usage

``` r
sl_boundaries(
  type,
  vintage = "latest",
  dir = sl_cache_dir(),
  codes = NULL,
  lookups = TRUE
)
```

## Arguments

- type:

  One of lsoa21, msoa21, ward, lad, pfa, region.

- vintage:

  A catalogue vintage (YYYY-MM), or latest.

- dir:

  Explicit cache directory.

- codes:

  Optional ONS codes to limit acquisition.

- lookups:

  Fetch and attach the ONS lookup tables.

## Value

An sf object with `geography_code`, `geography_name`, source metadata
and lookups, or NULL with a message when the source is unavailable.

## See also

[`sl_assign_geography()`](https://blackthrive.github.io/searchlight/reference/sl_assign_geography.md),
[`sl_population()`](https://blackthrive.github.io/searchlight/reference/sl_population.md)

Other ingest:
[`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md),
[`sl_archive_index()`](https://blackthrive.github.io/searchlight/reference/sl_archive_index.md),
[`sl_archive_snapshot()`](https://blackthrive.github.io/searchlight/reference/sl_archive_snapshot.md),
[`sl_assign_geography()`](https://blackthrive.github.io/searchlight/reference/sl_assign_geography.md),
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
boundaries <- readRDS(system.file("extdata", "sample-boundaries.rds",
  package = "searchlight"
))
boundaries$lsoa21[1, "geography_code"]
#> Simple feature collection with 1 feature and 1 field
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -1.764669 ymin: 53.84234 xmax: -1.746633 ymax: 53.85079
#> Geodetic CRS:  WGS 84
#>   geography_code                       geometry
#> 1      E01010568 POLYGON ((-1.749345 53.8490...
```
