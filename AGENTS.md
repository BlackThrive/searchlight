# searchlight: build specification for a coding agent

Save this file as `CLAUDE.md` (Claude Code) or `AGENTS.md` (Codex) at the root of an empty repository named `searchlight`. Read it in full before writing any code. Every section is a requirement unless marked "optional".

---

## 1. What this package is

`searchlight` is an R package for the analysis of police stop and search records in England and Wales, published by Black Thrive Global (BTG). It turns the public archive from data.police.uk into a versioned, audited, geography-assigned dataset and then estimates ethnic disparity in stop and search with methods that make their assumptions explicit and testable.

It has three layers, built in this order:

1. **Ingest and audit**: archive acquisition, revision handling, coverage audit, geography assignment, Census population matching, baseline rates.
2. **Sensitivity**: missing-ethnicity bounds, denominator scenarios, age/sex standardisation, ranking stability.
3. **Inference**: count models with exposure offsets, spatial hierarchical disparity models with ethnicity-specific spatial effects, outcome (hit-rate) diagnostics, veil-of-darkness tests.

Section 60 authorisation event studies are **out of scope** for the first release. Do not build them.

### Independence constraint (non-negotiable)

This package must be original work. Do **not** read, copy, adapt, or reproduce code from `policedatR` (JustKnowledge-UK), `ExtractSS` (Black Thrive), or `ukpolice` (Evan Odell). Do not add any of them as dependencies. You may cite the policedatR paper (Miles-Wilson & Okoroji 2026, Crime Science, doi:10.1186/s40163-025-00266-6) in documentation only to contrast approaches. If you find yourself needing to know how they solved a problem, solve it from the public data documentation instead.

### Design principles

- Acquisition is via the bulk archive, not per-polygon API requests. Geography is assigned locally by spatial join, so any ONS geography works without re-downloading.
- Every dataset carries an **ingestion contract** (section 4) describing provenance, coverage, and quality. Downstream functions read the contract and refuse or warn when assumptions are not met.
- "Force did not submit" is never represented as zero stops.
- Sampling uncertainty (intervals) and assumption uncertainty (sensitivity ranges) are reported separately and never merged.
- Stops are events, not persons. No function constructs a `population - stops` "not stopped" cell. Rates are modelled as counts with exposure offsets.
- No network access during `R CMD check`, tests, or examples.

---

## 2. Data sources (verify every URL and field name before use; they change)

Do not hardcode assumptions from this document without checking the live documentation. Record what you verified and when in `inst/NOTES/data_sources.md`.

### 2.1 Stop and search records: data.police.uk

- Archive index: https://data.police.uk/data/archive/ . Archive zips are published per month and contain a folder per month with one CSV per force named `YYYY-MM-<force-id>-stop-and-search.csv`. Confirm the exact zip naming and folder layout from the index page, and confirm how far back stop and search files exist (site states December 2014 onward, initially for a subset of forces).
- Data description and anonymisation: https://data.police.uk/about/ . Note that locations are anonymised by snapping to a fixed set of street-level points. This matters for section 5.4.
- Changelog of known issues, missing submissions and refreshes: https://data.police.uk/changelog/ . Parse or store it; it feeds the coverage audit.
- API documentation for field semantics and the warning that some forces supply dates without times (records appear at midnight): https://data.police.uk/docs/ . The API itself is **not** used for record acquisition. It may be used only for the static force list (`/api/forces`) with a bundled fallback copy in `inst/extdata`.
- Expected CSV columns (verify): Type, Date, Part of a policing operation, Policing operation, Latitude, Longitude, Gender, Age range, Self-defined ethnicity, Officer-defined ethnicity, Legislation, Object of search, Outcome, Outcome linked to object of search, Removal of more than just outer clothing.
- Licence: Open Government Licence v3.0. Attribute in `DESCRIPTION` and in any bundled sample.

### 2.2 Boundaries: ONS Open Geography Portal

- https://geoportal.statistics.gov.uk/ . Required layers, each with a documented vintage: LSOA 2021, MSOA 2021, Wards (current), Local Authority Districts (current), Police Force Areas, Regions. Use the ArcGIS REST/GeoJSON endpoints; store the layer id, vintage and retrieval date in the contract.
- Lookups: LSOA to MSOA to LAD to PFA to Region (ONS lookup tables). Ward to LAD lookup.

### 2.3 Population: Census 2021 via NOMIS API

- https://www.nomisweb.co.uk/api/v01/ . Verify which tables exist at which geographies. Candidates: TS021 (ethnic group) at LSOA/MSOA/LAD; a cross-tab of ethnic group by sex by age (e.g. RM031 or equivalent) at whatever geography it is published; workday population tables if published for 2021. If a cross-tab is not available at small-area level, document that standardisation is only offered at the geographies where it is.
- Ethnicity classifications: implement both the Census 19+1 detailed groups and the 5+1 aggregate (Asian, Black, Mixed, White, Other, Unknown), plus the Home Office/MoJ mapping between police self-defined ethnicity codes and Census groups. Officer-defined ethnicity uses a different, coarser scheme; keep the two separate and never merge them silently.

### 2.4 Benchmark: Home Office Police Powers and Procedures

- https://www.gov.uk/government/collections/police-powers-and-procedures-england-and-wales . Used only to cross-check annual force totals in the coverage audit. Bundle a small table of published force-year totals with source and retrieval date; do not download at runtime.

### 2.5 Astronomical data for veil of darkness

- Use the CRAN package `suncalc` to compute sunset and end of civil twilight from date, latitude, longitude. Handle UK daylight saving transitions explicitly.

---

## 3. Package skeleton

```
searchlight/
  DESCRIPTION
  NAMESPACE            (generated by roxygen2)
  LICENSE, LICENSE.md  (MIT; copyright holder Black Thrive Global)
  NEWS.md
  README.Rmd / README.md
  R/
    sl-package.R
    ingest-archive.R        sl_archive_index(), sl_archive_download(), sl_archive_snapshot()
    ingest-versions.R       sl_select_version(), sl_list_versions()
    ingest-parse.R          sl_read_records()
    ingest-geography.R      sl_boundaries(), sl_assign_geography()
    ingest-population.R     sl_population(), sl_population_crosstab()
    ingest-contract.R       sl_contract(), print/summary methods, validators
    audit-coverage.R        sl_coverage(), sl_coverage_compare(), sl_benchmark()
    audit-quality.R         sl_quality(), sl_timestamp_quality(), sl_location_quality()
    rates-baseline.R        sl_counts(), sl_rates(), sl_rate_ratio()
    sens-missing-ethnicity.R sl_missing_ethnicity_bounds()
    sens-denominator.R      sl_denominator_scenarios()
    sens-standardise.R      sl_standardise()
    sens-ranking.R          sl_ranking_stability()
    infer-count-models.R    sl_count_model()
    infer-spatial.R         sl_spatial_disparity()
    infer-outcome.R         sl_hit_rates()
    infer-veil.R            sl_veil_of_darkness()
    report.R                sl_report()
    cache.R                 sl_cache_dir(), sl_cache_clear()
    classifications.R       ethnicity mappings, legislation groupings, object/outcome groupings
    utils-*.R
  inst/
    extdata/                small bundled sample (section 8.3), force list, PPaP benchmark table, classification tables
    templates/              report Rmd/Quarto template
    scripts/                simulation study and benchmark scripts (not run at check)
    NOTES/data_sources.md
  tests/testthat/
  vignettes/
  data-raw/                scripts that build inst/extdata and any data/ objects
  .github/workflows/       R-CMD-check (ubuntu, macOS, windows; R release, devel, oldrel), test-coverage, pkgdown
  _pkgdown.yml
  codemeta.json (optional)
```

Function prefix: `sl_`. Every exported function has roxygen documentation with `@examples` that run on the bundled sample without network. Internal helpers are unexported and documented with `@noRd`.

---

## 4. The ingestion contract

Every records data frame produced by layer 1 is a tibble of class `c("sl_records", "tbl_df", "tbl", "data.frame")` with an attribute `contract` of class `sl_contract`, a named list with at least:

| Field | Content |
|---|---|
| `source` | "data.police.uk archive" |
| `snapshots` | data frame: archive file, sha256, download timestamp, URL |
| `versions` | data frame per force-month: force, month, archive file selected, alternative archives seen, selection rule |
| `coverage` | data frame per force-month: status in {`submitted`, `missing`, `refreshed`, `partial_suspected`}, n_records, changelog note |
| `geography` | list: geography type(s) assigned, ONS layer id, boundary vintage, CRS, retrieval date |
| `assignment_quality` | per geography: share of records with missing coordinates, share within a configurable distance (default 50 m) of a boundary |
| `timestamps` | per force-month: share of records at exactly 00:00:00, flag `time_reliable` (TRUE if share below threshold, default 5%) |
| `population` | list: NOMIS table id(s), Census vintage, classification (19+1 or 5+1), geography, retrieval date |
| `classification` | ethnicity scheme in use (self-defined or officer-defined), mapping version |
| `created` | timestamp, package version, R version |

Requirements:

- `sl_contract(x)` returns it; `print.sl_contract` gives a readable summary; `summary()` returns the coverage table.
- Contracts propagate through `dplyr` verbs and subsetting (implement `[`, `dplyr_reconstruct`), and through every `sl_` function that returns records or aggregates. Aggregated outputs (rates, models) carry a copy.
- Downstream functions check the contract: `sl_veil_of_darkness()` refuses force-months with `time_reliable = FALSE` and says so in output; `sl_rates()` warns when any included force-month is `missing` and excludes it from denominators of time; `sl_spatial_disparity()` warns when boundary-sensitive share exceeds a threshold.

---

## 5. Layer 1: ingest and audit

### 5.1 Archive acquisition

- `sl_archive_index()`: scrape or fetch the archive listing; return a tibble of archive files with month range and URL. Cache the listing.
- `sl_archive_download(months, forces = NULL, dir = sl_cache_dir())`: download only the archive zips needed, verify sha256, store zip and a manifest. Idempotent. Respect a user-set cache directory via `tools::R_user_dir("searchlight", "cache")`; never write elsewhere without an explicit `dir` argument. Show progress with `cli`.
- `sl_archive_snapshot(dir)`: extract stop-and-search CSVs only, keep them unmodified, record sha256 per CSV. Do not delete or rewrite source files.

### 5.2 Revision handling

The same force-month can appear in several archive zips because forces refresh data. Rule: never deduplicate rows. Instead:

- `sl_list_versions(dir)`: for each force-month, list every archive that contains it, with row count and CSV hash.
- `sl_select_version(versions, rule = c("latest", "earliest", "max_rows", "manual"))`: pick one version per force-month; record the rule and alternatives in the contract. Default `latest`. Emit a table of force-months where versions differ in row count by more than 1%.

### 5.3 Parsing

- `sl_read_records(dir, versions)`: read the selected CSVs with `readr` or `data.table::fread`, enforce a fixed schema (types, factor levels), standardise column names to snake_case, parse `Date` to POSIXct in `Europe/London`, derive `force_id` from filename, derive `month`. Keep raw strings for ethnicity in `self_defined_ethnicity_raw` and add mapped `ethnicity_5` and `ethnicity_19`, plus `ethnicity_officer`. Unknown/refused/blank map to `Unknown`, never dropped.
- Derived flags: `is_strip_search` (from removal of more than outer clothing), `legislation_group` (PACE s.1, Misuse of Drugs Act s.23, CJPOA s.60, Firearms Act, Terrorism Act, other; verify legislation strings from the data), `object_group`, `outcome_group` with three separate outcome measures: `any_action` (not NFA), `arrest`, `outcome_linked_to_object`.

### 5.4 Geography assignment

- `sl_boundaries(type, vintage = "latest", dir)`: fetch and cache ONS boundaries as `sf`, with lookups. Return object records layer id and vintage.
- `sl_assign_geography(records, boundaries, types = c("lsoa21", "msoa21", "ward", "lad", "pfa"))`: point-in-polygon join in a projected CRS (British National Grid, EPSG:27700). Records with missing coordinates get `NA` and are counted in the contract. For each assigned geography also compute `boundary_distance_m` (distance from point to nearest polygon boundary of the assigned unit) and `boundary_sensitive` (distance below threshold). Document that coordinates are anonymised snap points, so this is a systematic, not random, error.

### 5.5 Population

- `sl_population(geography, classification = c("5", "19"), dir)`: NOMIS Census 2021 ethnic group counts at the requested geography; cached; returns tibble with geography code, ethnicity, population, and metadata.
- `sl_population_crosstab(geography, dir)`: ethnicity by sex by age band where available. Return `NULL` with a clear message where not available at that geography.
- A user can supply their own exposure table (`sl_exposure()` constructor) with the same shape; it is tagged as `user_supplied` in the contract.

### 5.6 Coverage audit

- `sl_coverage(records, forces, months, changelog = NULL)`: full force × month grid. Status logic: present in a selected version and n > 0 → `submitted`; no CSV for that force-month in any archive → `missing`; multiple versions with differing counts → `refreshed`; present but n falls below a force-specific threshold (e.g. under 20% of that force's trailing 12-month median) or changelog flags an issue → `partial_suspected`. Output is a tibble plus a `plot()` method (heatmap, `ggplot2`).
- `sl_coverage_compare(coverage, period_a, period_b)`: returns whether the two periods are comparable for each force (same set of submitted months) and the list of force-months that break comparability.
- `sl_benchmark(records, ppap_table)`: annual force totals from records versus bundled Home Office PPaP totals, with ratio and flag beyond a tolerance. Document why they differ in principle (scope of powers, reporting basis).

### 5.7 Quality diagnostics

- `sl_timestamp_quality(records)`: per force-month share at 00:00:00; per force stability over time; sets `time_reliable`.
- `sl_location_quality(records)`: missing coordinate rate; share of records sharing the single most common coordinate in each LSOA (snap-point concentration); boundary-sensitive share.
- `sl_quality(records)`: wrapper that runs both and updates the contract.

### 5.8 Baseline counts and rates

- `sl_counts(records, by = c("pfa", "month", "ethnicity_5"), ...)`: grouped counts, with `Unknown` retained as a level and with zero-filled combinations for submitted force-months only.
- `sl_rates(counts, population, per = 1000)`: rate per 1000 resident population by group; time exposure is months actually submitted, not calendar months.
- `sl_rate_ratio(rates, reference = "White", comparison = "Black", method = c("poisson", "quasipoisson", "negbin"))`: rate ratio from a count model with `log(population)` offset and group indicator. Reports point estimate, interval, overdispersion diagnostic. This is a **stop-rate ratio** and the documentation must say it is not a person-level probability ratio. No 2x2 table.

---

## 6. Layer 2: sensitivity

- `sl_missing_ethnicity_bounds(counts, population, reference, comparison, scenarios = c("all_to_reference", "all_to_comparison", "proportional", "force_object_mar"))`: recompute the rate ratio under each allocation of `Unknown` records. Return a tibble with the ratio under each scenario, the extreme bounds, and the allocation share of Unknown to the comparison group at which the ratio crosses 1 (the "tipping allocation"). Report separately from the sampling interval.
- `sl_denominator_scenarios(counts, exposures = list(resident = ..., workday = ..., user = ...))`: rate ratios under each exposure table; a comparability check that all exposures use the same classification and geography.
- `sl_standardise(counts, crosstab, standard = c("england_wales", "study_population"))`: direct age-sex standardised stop rates by ethnicity, only at geographies where the crosstab exists. Return crude and standardised side by side.
- `sl_ranking_stability(rate_ratios, method = c("bootstrap", "posterior"), n = 1000)`: distribution of rank for each area under sampling uncertainty (parametric bootstrap from the count model, or posterior draws from layer 3), and optionally across sensitivity scenarios. Output: rank probability matrix and a summary of which pairwise differences are stable.

Every sensitivity output has class `sl_sensitivity` with a `print()` method that shows the interval and the sensitivity range on separate lines with labels "sampling uncertainty" and "assumption range".

---

## 7. Layer 3: inference

### 7.1 Count models

- `sl_count_model(counts, formula, family = c("poisson", "negbin"), offset = "population", random = NULL)`: thin wrapper around `stats::glm` / `MASS::glm.nb` and, when `random` is given, `lme4::glmer` or `glmmTMB`. Returns a tidy table plus dispersion and residual autocorrelation diagnostics (Moran's I on residuals when geography is present, via `spdep`).

### 7.2 Spatial disparity model

Purpose: estimate a smoothed surface of ethnic disparity at small-area level, with ethnicity-specific spatial effects, not a single shared spatial effect on total intensity.

- `sl_spatial_disparity(counts, population, boundaries, reference, comparison, backend = c("carbayes", "inla"), ...)`.
- Model: for area i and group g, counts ~ Poisson(E_ig × θ_ig), with log θ_ig = α_g + u_i + v_ig, where u_i is a shared structured spatial effect and v_ig is a group-specific structured effect (multivariate Leroux/CAR). The disparity surface is exp(α_c − α_r + v_ic − v_ir) with a full posterior.
- Default backend: `CARBayes::MVS.CARleroux` (CRAN) on a multivariate response (areas × groups). Optional backend: INLA with a BYM2 prior on both components; INLA is not on CRAN, so list it in `Suggests` with `Additional_repositories` in DESCRIPTION and test it only when installed.
- Output class `sl_spatial`: posterior summaries of the disparity ratio per area (median, 90% and 95% credible intervals), exceedance probabilities P(ratio > 1) and P(ratio > k), the crude ratio alongside for comparison, convergence diagnostics (R-hat, ESS), and an `sf` join helper for mapping. `plot()` produces crude vs smoothed maps side by side.
- Documentation must state what smoothing can and cannot do, and point to the simulation vignette for evidence.

### 7.3 Outcome diagnostics

- `sl_hit_rates(records, by = c("pfa", "object_group"), outcome = c("any_action", "arrest", "outcome_linked_to_object"), reference, comparison)`: hit rate per group with Wilson intervals, and a logistic model of the outcome on ethnicity with force and object fixed effects. Three outcomes are always computed separately. Documentation states the interpretation limits: hit rates condition on being searched and differing hit rates do not by themselves establish discrimination.

### 7.4 Veil of darkness

- `sl_veil_of_darkness(records, boundaries = NULL, twilight = c("civil", "sunset"), window = "intertwilight", design = c("intertwilight", "dst"))`.
- Steps: drop force-months with `time_reliable = FALSE` (report them); compute sunset and civil twilight end per record via `suncalc`; restrict to the inter-twilight window (between earliest and latest twilight across the year for that location); define `dark`; fit logistic regression of `comparison` group membership on `dark` with controls for time of day (splines or 15-minute bins), day of week, month, force; optional DST discontinuity design using the weeks around clock changes.
- Output: odds ratio of the comparison group being stopped in darkness, interval, sample size after each exclusion step, and an explicit list of assumptions. Documentation states the method was developed for vehicle stops and its assumptions must be assessed for pedestrian stop and search.

---

## 8. Package engineering requirements

### 8.1 DESCRIPTION

- `Package: searchlight`, `Title` in title case, `Version: 0.1.0`, `License: MIT + file LICENSE`.
- `Authors@R`: Mustapha Wasseja (aut, cre, with ORCID if provided), Sarah Hamed (aut), Souci Frissa (aut), Black Thrive Global (cph, fnd). Add collaborators as agreed.
- `Depends: R (>= 4.1.0)`.
- `Imports` (keep lean): cli, rlang, dplyr, tibble, tidyr, readr, httr2, jsonlite, sf, digest, ggplot2, MASS, CARBayes, spdep, suncalc, rappdirs or tools (R_user_dir).
- `Suggests`: testthat (>= 3.0.0), httptest2, knitr, rmarkdown, quarto, lme4, glmmTMB, INLA, withr, vdiffr, spelling, lintr.
- `Additional_repositories: https://inla.r-inla-download.org/R/stable` if INLA is in Suggests.
- `URL` and `BugReports` pointing to the BTG GitHub org repo.
- `Config/testthat/edition: 3`, `Encoding: UTF-8`, `Roxygen: list(markdown = TRUE)`, `RoxygenNote`, `VignetteBuilder: knitr`, `LazyData: true` only if a `data/` directory exists.

### 8.2 CRAN policy compliance (check each explicitly)

- No internet access in examples, tests, or vignettes. Network functions wrap all calls in `httptest2` fixtures for tests; examples use `\donttest{}` for network calls and run on the bundled sample otherwise; vignettes are precomputed (`vignettes/*.Rmd.orig` rendered by `data-raw/precompute_vignettes.R`) or use bundled data.
- Network functions fail gracefully with an informative message, never an error that halts check, when the resource is unavailable (CRAN policy on internet resources).
- No writing to the user's home directory or package library. Cache only in `tools::R_user_dir("searchlight", "cache")` and only after the user calls a function that documents this; tests use `withr::local_tempdir()`.
- Examples run in under 5 seconds each; tests use no more than 2 cores; spatial model tests use a tiny synthetic lattice and few MCMC iterations, and full-length runs are `skip_on_cran()`.
- Installed package size under 5 MB. Bundled sample data compressed with `tools::resaveRdaFiles` or stored as compressed CSV in `inst/extdata`.
- `R CMD check --as-cran` on R release, devel and oldrel across ubuntu, macOS, windows: 0 errors, 0 warnings, 0 notes (other than the "new submission" note). Run `rhub::rhub_check()` and win-builder devel before submission.
- `urlchecker::url_check()` clean. `spelling::spell_check_package()` clean with a `inst/WORDLIST`.
- All non-ASCII characters escaped or avoided in R source. `Encoding: UTF-8` set.
- No `T`/`F`, no `library()` calls inside functions, no `print()` for messages (use `cli`), no modifying global options or `par()` without `on.exit()` restore.
- `cran-comments.md` describing test environments and results.
- Reverse dependencies: none, state so.

### 8.3 Bundled sample data

- Build in `data-raw/sample.R`: real records for two forces (choose one metropolitan and one rural, e.g. a large city force and a small county force) for three months, all columns retained, plus matching LSOA/MSOA boundaries for those force areas (simplified with `rmapshaper` to keep size down) and Census 2021 ethnic group counts for those areas. OGL v3 attribution in `inst/extdata/README.md` and in the data documentation.
- Also build a **synthetic** dataset generator `sl_simulate()` (exported) that creates areas on a lattice with a known disparity surface, known population, and known missingness process. This is used by tests and the simulation vignette.

### 8.4 Testing

- `testthat` 3e, target ≥ 85% line coverage (`covr`), enforced in CI.
- Unit tests for every exported function.
- Contract propagation tests: after `filter()`, `[`, `mutate()`, `group_by() |> summarise()` via `sl_counts()`, the contract is still present and correct.
- Known-answer tests: `sl_rates()` and `sl_rate_ratio()` reproduce hand-computed values on a tiny fixture; `sl_missing_ethnicity_bounds()` returns the analytically known extreme bounds; `sl_standardise()` reproduces a textbook direct standardisation example.
- Recovery tests: on `sl_simulate()` output with a known disparity surface, `sl_spatial_disparity()` posterior medians correlate with truth above a stated threshold and 95% intervals cover truth at roughly nominal rate (run at reduced size on CRAN, full size in CI with `skip_on_cran()`).
- Coverage-status logic tests: missing vs zero vs refreshed vs partial each produce the correct status.
- Timestamp gating test: `sl_veil_of_darkness()` excludes a force-month with 100% midnight records and reports it.
- Geography tests: a point placed 10 m inside a boundary is assigned correctly and flagged boundary-sensitive; a point with NA coordinates is retained with NA geography.
- Snapshot tests (`vdiffr`) for `plot()` methods, skipped on CRAN.
- `httptest2` fixtures for archive index, NOMIS, and ONS calls; a test that all network functions return a graceful message when offline (`withr::local_envvar(NO_INTERNET_TEST = "true")` or `httptest2::without_internet()`).

### 8.5 Documentation

- roxygen2 for everything; `@family` tags per layer; `@seealso` cross-links.
- README with a 15-line quick start on the bundled sample.
- Vignettes (precomputed): (1) "From archive to audited dataset", (2) "Estimating disparity with explicit assumptions" (rates, count models, missing-ethnicity bounds, denominators, standardisation), (3) "Small-area disparity with spatial smoothing: simulation evidence", (4) "Outcome tests and veil of darkness".
- pkgdown site with reference grouped by layer; deploy via GitHub Actions.
- `NEWS.md` from 0.1.0 onward.
- A `vignette("methods")` or `inst/NOTES/methods.md` giving the statistical definitions, model equations, and the interpretation limits listed in sections 5.8, 6, 7.3, 7.4.

### 8.6 Code style and tooling

- `styler` tidyverse style; `lintr` with the default linters plus `object_usage_linter`; both run in CI.
- Use `cli` for all messages; use `rlang::abort()`/`warn()` with `class` arguments so users can catch specific conditions (`searchlight_error_contract`, `searchlight_warning_coverage`, etc.).
- Functions take and return tibbles; no side effects except explicit cache writes.
- Commit in small, reviewable steps with conventional commit messages. Open one pull request per milestone (section 9) with the checklist in its description.

---

## 9. Milestones and acceptance criteria

Work through these in order. Do not start a milestone until the previous one passes its acceptance criteria and `R CMD check` is clean.

**M0: Skeleton (day 1)**
`usethis::create_package()`, licence, README, CI workflows, testthat, pkgdown, lintr, pre-commit. `R CMD check` clean on an empty package. Bundle force list and classification tables with tests that they load.

**M1: Archive ingestion and versioning**
`sl_archive_index()`, `sl_archive_download()`, `sl_archive_snapshot()`, `sl_list_versions()`, `sl_select_version()`, `sl_read_records()`, `sl_contract()` with print/summary. Acceptance: httptest2-backed tests pass; ingest the two-force sample end to end from fixtures; contract fields `source`, `snapshots`, `versions`, `timestamps`, `classification` populated; a force-month present in two archives with different counts is reported and only one version selected.

**M2: Geography, population, coverage, quality**
`sl_boundaries()`, `sl_assign_geography()`, `sl_population()`, `sl_population_crosstab()`, `sl_coverage()`, `sl_coverage_compare()`, `sl_benchmark()`, `sl_timestamp_quality()`, `sl_location_quality()`. Acceptance: all contract fields populated; coverage heatmap renders; boundary-sensitivity and midnight-share diagnostics computed on the sample; benchmark table compares to bundled PPaP totals.

**M3: Baseline rates and sensitivity**
`sl_counts()`, `sl_rates()`, `sl_rate_ratio()`, `sl_missing_ethnicity_bounds()`, `sl_denominator_scenarios()`, `sl_standardise()`, `sl_ranking_stability()`, `sl_sensitivity` print method. Acceptance: known-answer tests pass; printed output separates sampling interval from assumption range; vignette 2 renders.

**M4: Inference**
`sl_count_model()`, `sl_spatial_disparity()` (CARBayes backend), `sl_hit_rates()`, `sl_veil_of_darkness()`, `sl_simulate()`. Acceptance: recovery tests on simulated data pass; the model has group-specific spatial effects (verify by simulating a disparity surface uncorrelated with total intensity and recovering it); veil-of-darkness gating works; vignettes 3 and 4 render.

**M5: Reporting and release**
`sl_report()` rendering the template to HTML with estimates, assumptions, coverage table, sources and limitations. Full `R CMD check --as-cran` matrix clean, rhub and win-builder clean, coverage ≥ 85%, `urlchecker` and `spelling` clean, `cran-comments.md` written, `NEWS.md` at 0.1.0, pkgdown deployed. Produce a release checklist output confirming each item.

**Later (not in 0.1.0)**: INLA backend, workday and mobility-based exposure helpers, Section 60 evaluation once an authorisation register exists.

---

## 10. Validation evidence to produce (in `inst/scripts/`, run in CI on a schedule, not at check)

1. **Benchmark**: time to build a 12-month national dataset at MSOA level from the archive versus a naive alternative; report in the README as a measured number, not a claim.
2. **Simulation study**: across replicated lattices with (a) smooth disparity surfaces, (b) surfaces with sharp local discontinuities, (c) small comparison-group populations, compare crude ratios and smoothed estimates on RMSE, interval coverage, and rank recovery. Report where smoothing helps and where it hurts. This is the evidence for vignette 3.
3. **Missingness study**: simulate unknown-ethnicity records under MCAR, MAR-by-force, and MNAR-by-ethnicity; show the bounds contain the truth and how wide they get.
4. **Reproduction**: recompute crude force-level Black-White rate ratios for a recent 12-month period independently and store as a fixture; the package must reproduce them exactly.

---

## 11. Things to avoid

- Any `population - stops` construction.
- Silent dropping of `Unknown` ethnicity.
- Treating an absent force-month as zero.
- Row-level deduplication across archive versions.
- Merging officer-defined and self-defined ethnicity.
- Network calls in tests, examples, or vignettes.
- Claims in documentation that smoothing "corrects" small-area estimates; say "stabilises under stated assumptions" and point to the simulation evidence.
- Reading or importing code from policedatR, ExtractSS, or ukpolice.

---

## 12. Operating rules for the agent (read before every session)

The maintainer will not be available to answer routine questions. Do not stop to ask. Apply the defaults below, record every choice in `inst/NOTES/decisions.md` with date and reason, and move on. The maintainer reviews that file at each milestone.

### 12.1 Defaults for open decisions

| Decision | Default |
|---|---|
| Licence | MIT + file LICENSE, copyright holder "Black Thrive Global" |
| Maintainer | Mustapha Wasseja, role `c("aut", "cre")`; leave ORCID out until supplied |
| Coauthors | Sarah Hamed (`Sarah.Hamed@blackthrive.org`) and Souci Frissa (`Souci.Frissa@blackthrive.org`), each with role `"aut"` (maintainer instruction, 2026-09-22). |
| Attribution | Do not credit AI or Codex as an author or co-author in package metadata, documentation or commits (maintainer instruction, 2026-09-21). |
| Copyright/funder | Black Thrive Global, role `c("cph", "fnd")` |
| Repository URL | `https://github.com/BlackThrive/searchlight` (owner corrected by the maintainer on 2026-09-21) |
| Sample forces | Metropolitan: `west-yorkshire`. Rural: `dyfed-powys`. Months: the three most recent complete months available in the archive at build time. If a force has a missing month in that window, keep it (it is a useful test of coverage logic). |
| Sample geographies | LSOA 2021 and MSOA 2021 boundaries clipped to those two force areas, simplified to keep `inst/extdata` under 2 MB |
| Cache location | `tools::R_user_dir("searchlight", "cache")` |
| Boundary-sensitivity threshold | 50 m |
| Midnight-share threshold for `time_reliable` | 5% |
| Partial-submission threshold | count below 20% of the force's trailing 12-month median |
| Version selection rule | `latest` |
| Ethnicity classification default | self-defined, 5+1 |
| Reference and comparison groups default | White and Black |
| Spatial model backend | CARBayes; MCMC defaults `burnin = 2000, n.sample = 12000, thin = 10` for real runs, `burnin = 50, n.sample = 200` in tests |
| Credible interval levels | 90% and 95% |
| Rate denominator unit | per 1000 population |
| Data frame engine | dplyr/tibble for user-facing objects; `data.table::fread` allowed internally for reading only if it measurably speeds up M1, otherwise `readr` |

### 12.2 When a data source does not match this document

If a URL, table code, column name or archive layout differs from sections 2 and 5: use what the live source actually provides, write the discrepancy to `inst/NOTES/data_sources.md`, adjust the code, and continue. Do not wait for confirmation. If a source is unavailable for more than one session, build against the bundled fixtures and leave a `TODO(source)` comment plus a note.

### 12.3 When two requirements conflict

Priority order: (1) CRAN policy compliance, (2) the independence constraint, (3) statistical correctness as specified in sections 5 to 7, (4) everything else. Record the conflict and the resolution in `decisions.md`.

### 12.4 Session protocol

At the start of each session: read this file, read `inst/NOTES/decisions.md`, run `devtools::check()`, and continue from the first failing or unfinished item in the current milestone. At the end of each session: ensure check is clean or the failure is documented in `decisions.md` with a plan, commit, and append a three-line progress note to `inst/NOTES/progress.md` (milestone, what was completed, what is next).

### 12.5 The only questions worth escalating

Stop and write a question in `inst/NOTES/questions.md` (do not block on it; continue with the default) only for: a licence change request found in the repo, a data source whose licence is not OGL v3 or equivalent, or evidence that a required Census cross-tab is unavailable at every geography (which would remove `sl_standardise()` from scope).

### 12.6 Definition of done for the whole project

`sl_report()` runs end to end on the bundled sample without network; every milestone acceptance criterion in section 9 is met; the validation scripts in section 10 have been run once and their outputs committed under `inst/validation/`; `R CMD check --as-cran` is clean on the full CI matrix; `cran-comments.md` and `NEWS.md` are complete. When all of these hold, write `RELEASE_READY.md` at the repo root summarising evidence for each item. Do not submit to CRAN; the maintainer does that.

---

## 13. References to cite in documentation

- Miles-Wilson, J. & Okoroji, C. (2026). policedatR. Crime Science 15:11. (contrast only)
- Ratcliffe, J. H. & Hyland, S. S. (2025). Police stops and naïve denominators. Crime Science 14:10.
- Grogger, J. & Ridgeway, G. (2006). Testing for racial profiling in traffic stops from behind a veil of darkness. JASA 101(475).
- Knowles, J., Persico, N. & Todd, P. (2001). Racial bias in motor vehicle searches. JPE 109(1).
- Riebler, A. et al. (2016). An intuitive Bayesian spatial model for disease mapping that accounts for scaling. Stat Methods Med Res 25(4). (BYM2)
- Knorr-Held, L. & Best, N. G. (2001). A shared component model for detecting joint and selective clustering of two diseases. JRSS A 164(1).
- Lee, D. (2013). CARBayes: An R package for Bayesian spatial modeling with conditional autoregressive priors. JSS 55(13).
- Manski, C. F. (2003). Partial Identification of Probability Distributions. (bounds under missing data)
- Home Office, Police powers and procedures England and Wales (annual).
- ONS (2023). Ethnic group classifications: Census 2021.
