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

## 2026-09-16: M3

* Use submitted population-years for annualised rates, and retain period_rate
  separately. Keep force and month in count grids even when not requested in by;
  additional event characteristics must be collapsed before reusing exposure.
* Use exact conditional Poisson ratio intervals, including zero-group limits.
  Do not add pseudocounts. Quasi-Poisson uses residual-df Student t intervals.
* Direct standardisation uses conservative simultaneous exact Poisson stratum
  limits, avoiding a misleading zero-width interval when no events are observed.
  Unknown age/sex exclusions and zero-population strata remain explicit.
* Preserve complete force-area lookup units in the sample contract. A filtered
  event subset retains the original time window, unless months are passed.
* Force-object MAR is explicitly unavailable if object_group was not counted;
  extreme and proportional scenarios remain usable. Positive unknown-only MAR
  strata require more information and are refused rather than guessed.
* Bootstrap ranks use the fitted count distribution and retain scenario models.
  Quasi-Poisson has no count distribution and is refused for this bootstrap.
  Delegate temporary random seed handling to withr so RNG state is restored
  without package-level assignments to the global environment.
* Bundle small derived example tables for four sample MSOAs so every example
  stays under five seconds without concealing the full sample or its missing force.
* Downloaded official Pandoc 3.11 portable Windows build for local vignette QA;
  SHA-256 2ab72baf2399450e148ddf7a2a8689806c42e1bba71862b57e220fd9b8456d3d
  matches the publisher. Binary lives only in the ignored project cache. The
  developer runtime helper selects it if no Pandoc is installed; package runtime
  never downloads executables. Precomputed vignettes contain static results and
  embedded figures, with no remote MathJax or syntax-highlighting dependency.

## 2026-09-16: M4

* Use the documented CARBayes 6.1.1 multivariate Poisson model with a matrix
  response, group-specific intercepts and population-time offsets. A bivariate
  MCAR field has an exact shared/contrast representation: u=(phi_r+phi_c)/2,
  v_r=(phi_r-phi_c)/2, v_c=-v_r. The components inherit covariance from the MCAR
  prior; do not mislabel them as three independently identifiable spatial fields.
  The disparity posterior includes both intercept and spatial differences.
* Verify area/group ordering by independently reconstructing posterior ratios
  from fitted event means and exposures. CARBayes stores group varying fastest.
* Use two chains on one core. Report rank-normalised split R-hat and bulk/tail
  ESS for every area log-ratio and monitored global parameter. Flag R-hat above
  1.01 or either ESS below 400. Tiny tests intentionally trigger this flag.
  Independent simulation seeds and convergence-driven extensions are recorded;
  seeds are never selected on whether smoothing outperforms the crude ratio.
* Default to rook adjacency and refuse isolated areas unless the user supplies
  a justified named adjacency matrix. Do not fabricate nearest-neighbour links.
  INLA remains deferred per the explicit first-release milestone scope.
* Simulation intensity varies north-south and disparity east-west, with exactly
  zero lattice correlation. Solve group rates to keep expected total intensity
  fixed as disparity changes. Missingness thins recorded events without deleting
  their Unknown rows. Distinguish generating rate ratios from realised ratios.
* Keep outcome measures separate and use Wilson intervals among observed outcomes.
  Pairwise logistic models include force/object fixed effects where variable;
  report constant controls and missing/unknown exclusions. Withhold intervals
  from failed, aliased, warning-producing or numerically extreme logistic fits.
* Compute annual twilight bounds at each published location. Civil darkness
  excludes the sunset-to-dusk transition. Europe/London supplies clock changes;
  DST is a local darkness comparison with running-day and transition controls,
  not an automatic causal regression discontinuity claim. Missing coordinates
  are excluded, not replaced by centroids. Retain each exclusion stage and the
  force-month time gate. Passing the gate is not proof of accurate timestamps.
* The sparse-population pilot retains failed convergence after the predeclared
  12,000 / 40,000 / 80,000 iteration sequence. A separate seed-1501 probe with
  MALA enabled and disabled failed the same strict diagnostic screen; keep the
  original sampler and priors throughout the reported study. Do not select an
  algorithm or seed based on improved recovery. Failed fits remain labelled in
  tables and plots, and local error summaries separate convergence status.
* Interrupted validation output exposed incomplete area-level checkpoints.
  Resume now verifies all 25 areas for both methods before accepting a replicate;
  incomplete smooth replicates 2 and 3 are rerun with identical seeds/settings.
  Subsequent attempts also retain parameter-level diagnostics. Earlier completed
  replicates retain their recorded overall convergence flags; missing historical
  parameter diagnostics are not reconstructed or invented.
* Real-sample outcome validation exposed a missing archive text alias for
  "Any other Black/African/Caribbean background". Correct all 58 affected sample
  events from Unknown to Other Black / Black, version the text mapping, rebuild
  derived rate/sensitivity examples and vignettes, and add raw-label regression
  tests. Immutable source files and spatial assignments are unaffected. Unknown
  blank/not-stated records remain 2,280. Unexpected future labels now raise a
  typed classification warning rather than silently becoming Unknown.
* Full-sample darkness validation showed excessive overhead from one solar
  request per location-year. Batch up to 64 location-years per call using the
  documented suncalc data-frame interface, retaining every exact coordinate and
  calendar date. Bound memory without replacing locations or approximating the
  annual window. Compare against independent single-location calls, including
  a leap year and repeated coordinates in different years.
* Declare CARBayes >=6.1.1, the verified multichain matrix-response API, and
  explicitly import splines::ns because its use inside a fitted-formula string
  is not detected by the static dependency check. These are dependency metadata
  corrections; neither changes numerical inference.
* The first installed example timing run was below five seconds per topic, but
  a subsequent run under concurrent workstation load exposed slow initialisation
  of plotting, spatial-diagnostic and CSV-reader namespaces. Keep installed
  examples minimal: print the coverage table, fit the basic count model and read
  the tiny benchmark table with base R. Vignettes and dedicated tests still
  exercise the heatmap, Moran diagnostic and ordinary bundled-table reader.
* Read the tiny bundled metadata tables with base read.csv, preserving character
  columns and explicit blank/NA handling, then return a tibble. Loading readr
  solely for a few metadata rows imposed avoidable namespace startup costs.
  Bulk archive parsing still uses readr with its fixed schema.
* M4 gate passed locally: zero errors/warnings/notes, 343 installed assertions,
  no test warnings, all examples below five seconds (maximum 1.68 seconds),
  and clean lint. Full recovery and visual snapshots passed in the separate
  NOT_CRAN coverage run (94.7%). Retain the same disclosed offline incoming,
  clock and manual-PDF exclusions as earlier milestone checks. These local
  results do not assert that the external release matrix has run.
