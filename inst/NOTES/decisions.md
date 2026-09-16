# Decisions

## 2026-09-16: M0

* Created `searchlight/` as an independent Git repository within the supplied
  workspace; existing applications were not read or used as source material.
  Saved the supplied specification verbatim as AGENTS.md and read it in full.
* Used `usethis::create_package()` and MIT licence scaffolding. No existing package
  was present, so the initial session check starts after the skeleton is written.
* Maintainer email comes from the user's configured Git identity. Name and roles
  follow the specification; no ORCID is invented.
* Add runtime dependencies when first used to avoid unused-import check notes on
  earlier milestones. Defer VignetteBuilder until there are actual vignettes.
* R 4.5.2 is available. The inherited C.UTF-8 locale is unsupported by this
  Windows R build; check commands use en_US.UTF-8 process-local environment.
* The specified GitHub URL does not resolve for the authenticated account.
  Keep it as the required placeholder, record URL-check failure honestly, and
  prepare local milestone PR descriptions. Do not create a different remote
  or claim that CI, hosted documentation, rhub, or win-builder have run.
* Official archive checksums are MD5. Verify MD5 before creating a SHA-256 manifest;
  the latter detects later corruption, and is not a publisher-authenticated hash.
* PACE 2023 includes Roma. Pin the code mapping version; historical numeric or
  abbreviated codes must not be silently interpreted using an incompatible scheme.
* The first as-CRAN check reported only an inability to verify the current time
  over the network. Set `_R_CHECK_SYSTEM_CLOCK_=FALSE` for offline local/CI checks;
  this avoids an unrelated external clock request and is disclosed in results.

## 2026-09-16: M1

* The latest three complete available months are May-July 2026. The requested
  Dyfed-Powys files are absent in the latest bulk snapshot. Retain this force and
  missingness in the contract, per the specified default; do not replace it or
  invent records. Synthetic two-force archives independently test ingestion.
* Bundled sample CSVs are byte-preserving gzip copies. Manifests retain both the
  original CSV SHA-256 and the compressed-file SHA-256, plus full archive SHA-256.
* Retain unknown outcomes as NA for each binary measure. The presence of an NFA
  outcome does not override an independently reported linked-to-object flag.
* Source coverage remains provenance after filtering; a separate contract scope
  describes current rows. An analysis filter must not rewrite source submission
  status. Retain both the requested force-month grid and selected versions.
* Skip the malformed checksum on 2019-06.zip when choosing downloads; its
  published multipart-style value is retained in the index for audit.

## 2026-09-16: M2

* Pin the published ONSGeography_data services. New EU1 ONSGeography services
  label themselves alpha until March 2027; they are not the default source.
  Latest means latest verified catalogue vintage, recorded in every acquisition.
* Keep whole Census units selected through the official nine LADs in the two
  sample forces. Geometric clipping could leave a partial polygon with a full
  Census population and create a false denominator. The sample uses whole units
  and records this resolution of the clipping requirement.
* Assign sample points using the original BGC 20 m boundaries. Bundle separately
  simplified mapshaper geometries (keep 0.2, keep_shapes) for compact examples.
  Distances to anonymised points are diagnostics, not location-error corrections.
* ONS lookup vintages differ. Return them separately with source identifiers;
  do not silently join changing LAD codes across years. The nine sample LAD
  codes are unchanged. Current LAD/ward sf layers cannot be passed as Census
  2021 population geography without an explicit compatibility decision.
* RM032, not RM031, provides ethnicity by age and sex at LSOA/MSOA. Match stable
  Census codes (for example _13), not NOMIS numeric category IDs: TS021 and
  RM032 order the categories differently. Harmonise age to under 25, 25-34, 35+.
  Police-recorded gender and Census sex require a stated measurement assumption.
* Unknown ethnicity has NA population; never assign it zero or a fabricated
  Census count. User exposures must declare geography and classification.
* A zero-row CSV is a submission; a count below the trailing median threshold
  can still flag suspected partial submission. Coverage uses original file
  counts, not filtered analysis counts. Missing always retains NA counts.
* Include source-clock midnight in the timestamp gate as well as London midnight
  so UTC-stamped date-only records in summer cannot evade the diagnostic.
* Bundle the complete retrieved changelog HTML and a conservative structured
  extract for the sample's three unresolved Dyfed-Powys submissions. Historical
  notices are not automatically marked current issues after later refreshes.
  Other analyses can supply a resolved force/month/issue changelog table.
* Home Office SS_20 includes 43 territorial forces and British Transport Police;
  the static API force list excludes BTP and includes Northern Ireland. Benchmark
  identifiers include BTP explicitly and cover all 44 published force totals.
  Withhold ratios for incomplete financial years or filtered event records.
* Import one sf symbol so sf registers its subsetting methods at package load.
  Installed-package examples exposed that reading an sf RDS and subsetting it
  before first using sf:: could otherwise dispatch to base data-frame methods.
  Developer tests had already loaded sf and did not expose that session-order bug.
* Explicitly cap test/check reader, BLAS and OpenMP resources at two threads.
  The installed readr default detects twelve logical cores; test-local options
  and environment limits are restored at teardown. CI carries the same cap.
* Run local package checks in a fresh R temporary directory and copy the logs
  back. A reused directory under Dropbox produced an intermittent Windows
  staged-install rename denial. This is a filesystem warning, not suppressed;
  the isolated check must pass normally before accepting the milestone.
