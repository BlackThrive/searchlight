# Package index

## Archive, provenance and exposure

- [`sl_archive_download()`](https://blackthrive.github.io/searchlight/reference/sl_archive_download.md)
  : Download and verify the necessary archive snapshots
- [`sl_archive_index()`](https://blackthrive.github.io/searchlight/reference/sl_archive_index.md)
  : List available bulk archive snapshots
- [`sl_archive_snapshot()`](https://blackthrive.github.io/searchlight/reference/sl_archive_snapshot.md)
  : Extract immutable stop and search CSV snapshots
- [`sl_list_versions()`](https://blackthrive.github.io/searchlight/reference/sl_list_versions.md)
  : List force-month archive versions
- [`sl_select_version()`](https://blackthrive.github.io/searchlight/reference/sl_select_version.md)
  : Select one complete version per force-month
- [`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md)
  : Read selected immutable archive records
- [`sl_sample()`](https://blackthrive.github.io/searchlight/reference/sl_sample.md)
  : Load the bundled real archive sample
- [`sl_contract()`](https://blackthrive.github.io/searchlight/reference/sl_contract.md)
  : Inspect an ingestion contract
- [`sl_boundaries()`](https://blackthrive.github.io/searchlight/reference/sl_boundaries.md)
  : Fetch a versioned ONS boundary layer
- [`sl_assign_geography()`](https://blackthrive.github.io/searchlight/reference/sl_assign_geography.md)
  : Assign anonymised points to local geographies
- [`sl_population()`](https://blackthrive.github.io/searchlight/reference/sl_population.md)
  : Census 2021 ethnicity populations
- [`sl_population_crosstab()`](https://blackthrive.github.io/searchlight/reference/sl_population_crosstab.md)
  : Census ethnicity by age and sex
- [`sl_exposure()`](https://blackthrive.github.io/searchlight/reference/sl_exposure.md)
  : Construct an explicit exposure table
- [`sl_cache_clear()`](https://blackthrive.github.io/searchlight/reference/sl_cache_clear.md)
  : Clear a marked searchlight cache
- [`sl_cache_dir()`](https://blackthrive.github.io/searchlight/reference/sl_cache_dir.md)
  : Locate the searchlight cache

## Coverage and quality

- [`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md)
  : Audit submission coverage on a full force-month grid
- [`sl_coverage_compare()`](https://blackthrive.github.io/searchlight/reference/sl_coverage_compare.md)
  : Compare coverage patterns across two periods
- [`sl_benchmark()`](https://blackthrive.github.io/searchlight/reference/sl_benchmark.md)
  : Cross-check annual totals against the Home Office
- [`sl_quality()`](https://blackthrive.github.io/searchlight/reference/sl_quality.md)
  : Attach submission, timestamp and location diagnostics
- [`sl_timestamp_quality()`](https://blackthrive.github.io/searchlight/reference/sl_timestamp_quality.md)
  : Diagnose timestamp completeness and midnight heaping
- [`sl_location_quality()`](https://blackthrive.github.io/searchlight/reference/sl_location_quality.md)
  : Diagnose anonymised location quality

## Event rates and sensitivity

- [`sl_counts()`](https://blackthrive.github.io/searchlight/reference/sl_counts.md)
  : Count events while preserving submission strata
- [`sl_rates()`](https://blackthrive.github.io/searchlight/reference/sl_rates.md)
  : Calculate rates using observed population-time exposure
- [`sl_rate_ratio()`](https://blackthrive.github.io/searchlight/reference/sl_rate_ratio.md)
  : Estimate an event stop-rate ratio with exposure offsets
- [`sl_missing_ethnicity_bounds()`](https://blackthrive.github.io/searchlight/reference/sl_missing_ethnicity_bounds.md)
  : Bound disparity under allocations of Unknown ethnicity
- [`sl_denominator_scenarios()`](https://blackthrive.github.io/searchlight/reference/sl_denominator_scenarios.md)
  : Compare compatible population denominator scenarios
- [`sl_standardise()`](https://blackthrive.github.io/searchlight/reference/sl_standardise.md)
  : Directly standardise age-sex stop-event rates
- [`sl_ranking_stability()`](https://blackthrive.github.io/searchlight/reference/sl_ranking_stability.md)
  : Assess area rank uncertainty under count models or posterior draws

## Inference and simulation

- [`sl_count_model()`](https://blackthrive.github.io/searchlight/reference/sl_count_model.md)
  : Fit count models with population-time exposure
- [`sl_spatial_disparity()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_disparity.md)
  : Estimate a multivariate spatial stop-rate disparity surface
- [`sl_spatial_map()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_map.md)
  : Join spatial posterior summaries to their polygons
- [`sl_hit_rates()`](https://blackthrive.github.io/searchlight/reference/sl_hit_rates.md)
  : Describe three separate outcomes conditional on being searched
- [`sl_veil_of_darkness()`](https://blackthrive.github.io/searchlight/reference/sl_veil_of_darkness.md)
  : Diagnose ethnicity composition in daylight and darkness
- [`sl_simulate()`](https://blackthrive.github.io/searchlight/reference/sl_simulate.md)
  : Simulate event counts with independent disparity and total intensity

## Reporting

- [`sl_report()`](https://blackthrive.github.io/searchlight/reference/sl_report.md)
  : Write an offline report of audited records and analysis results
