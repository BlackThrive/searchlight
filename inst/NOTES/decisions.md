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

## 2026-09-16: M5

* Render an installed Markdown/Rmd report template with commonmark and inline
  CSS. This produces offline HTML without requiring Pandoc or executing models
  inside a report. Require explicit output paths and opt-in overwriting. Escape
  supplied text, display result-specific scope/diagnostics, label truncation,
  and separate sampling uncertainty from assumption ranges.
* Preserve the filename's submission month when London conversion of an explicit
  source offset crosses midnight into another month. Accept timestamps matching
  either source or London clock month, flag London mismatches and retain raw
  strings. Continue refusing dates belonging to neither month. This prevents a
  valid late-month UTC record from blocking national archive ingestion.
* National spatial assignment processes each exact published coordinate once,
  then restores every event's assignment. This is computational reuse, never
  event deduplication. Compute polygon boundaries once and point-edge distances
  in batches of at most 2,000 points to bound temporary geometry memory. Quality
  summaries still weight events, including repeated coordinates.
* Independent national reproduction found that entirely unsubmitted forces had
  undefined ratios but zero counts in the ratio summary, because summing an
  empty model frame returned zero. Keep reference/comparison and Unknown counts
  unavailable (NA) when no submitted data exist. Submitted zero-event groups
  still remain zero. Add both synthetic and independent real-fixture regressions.
* Keep independent force-ratio reference construction separate from the package:
  Python standard-library CSV parsing, raw broad ethnicity labels, and public
  NOMIS cells aggregated with the ONS LAD22-PFA22 lookup. Compare all monthly
  counts before comparing ratios; flag incomplete years explicitly. This checks
  arithmetic and ingestion, not the substantive validity of resident exposure.
* The missingness study targets the complete realised event ratio for exact
  containment. Latent generating ratios additionally vary through Poisson
  sampling; report their containment separately without relabelling allocation
  bounds as confidence intervals. Run twenty replicates per mechanism/rate cell.
* Use the canonical R-hub v1 workflow unchanged. The mandated repository URL
  still cannot be resolved by the authenticated GitHub account. Keep remote
  checks and deployment pending; do not replace the repository or manufacture
  successful external results.
* Spelling review caught a developer-only whitespace regular expression that
  also stripped a literal final t with R's default regex engine. Use the POSIX
  blank-character class and regenerate help pages and vignette HTML from source.
  Do not whitelist these damaged words. The package's analysis code is unaffected.
* Two long-running R sessions ended unexpectedly during national benchmarking
  and documentation generation, without a recorded R error. Preserve completed
  missingness and coverage outputs. Restart only unfinished work sequentially,
  add benchmark stage progress, and do not infer success from partial artifacts.
* Treat report titles and statements as literal HTML text, including newlines.
  Escaping angle brackets alone does not prevent a Markdown image in a title
  from loading an external asset. Wrap the title and encode line breaks before
  Markdown rendering; extend the offline-report regression with image syntax.
* A local TinyTeX installation is now available. Include PDF-manual generation
  in the final M5 check; earlier milestones retain their disclosed no-manual
  exception. Keep the local check offline, with incoming and clock probes
  excluded. These remain distinct from the pending external check matrix.
* National assignment equality passed, but the benchmark's whole-object count
  comparison also compared ingestion metadata such as creation timestamps.
  Compare every aggregate column exactly, retain assignment checks, checkpoint
  diagnostics, and rerun the monthly method against the saved national result.
  Disclose this resumed comparison and uncontrolled OS cache/workstation load.
* Build pkgdown in a temporary source copy outside Dropbox, then copy finished
  pages back. The first in-workspace build encountered a locked temporary
  --find-assets.html file; completed statistical outputs were unaffected.
* Final visual review found a printed bootstrap error in the assumptions
  vignette: one example area has zero Black events. Display that exclusion and
  rank the three eligible areas; retain all four in rates and sensitivity.
  Correct the quick start and make vignette generation fail on unexpected errors.
* On Windows, R CMD build copies the source tree before applying .Rbuildignore.
  The national cache now exceeds 2 GB. Stage only standard package inputs into
  a temporary directory for local checks and source builds, retaining all R,
  help, tests, vignettes and installed resources. This avoids copying research
  caches and avoids Dropbox locks without weakening any check.
* Final local M5 check passed with PDF/HTML manuals: zero errors, warnings and
  notes, 392 assertions, maximum example time 2.25 seconds, installed size
  2,943,212 bytes and extdata 810,818 bytes. Full developer recovery/snapshot
  tests passed under coverage (94.9358%). Style, lint and spelling are clean.
  R-hub was attempted and returned Not Found for the required repository.
  Keep the external matrix, URL failures, deployment and hosted-check results
  explicit; do not create RELEASE_READY.md or submit to CRAN.
* Win-builder's FTP data connection timed out without confirmation. The official
  HTTPS R-devel form then acknowledged searchlight_0.1.0.tar.gz and its exact
  1,618,183-byte size. Save both attempts with the archive SHA-256; the emailed
  check result remains unverified. An upload receipt is not a passing check.

## 2026-09-16: Win-builder result review

* Retrieved the result URL supplied by the maintainer and preserved the logs
  and Windows binary before their expiry. R-devel on Windows Server 2022 reports
  zero errors, zero warnings and one incoming NOTE. All 392 assertions passed;
  the two intended CRAN skips remain. Examples, vignettes and both manuals pass.
* The NOTE combines the expected new-submission notice, three unavailable
  GitHub/site URLs, and two README links to repository files excluded from the
  source archive. Replace the latter with plain filename references. Keep the
  required repository placeholders until the maintainer supplies an accessible
  repository; do not report this result as clean apart from new submission.
* Preserve the uploaded source archive and its recorded hash. This receipt
  describes that artifact, before the README edit; no new win-builder upload or
  CRAN submission is performed. Normalise only line endings and trailing blanks
  in committed console transcripts; retain raw downloads and both hashes.

## 2026-09-21: Maintainer-confirmed GitHub owner

* The maintainer supplied https://github.com/BlackThrive as the intended owner.
  Replace the original placeholder owner in package metadata, pkgdown and R-hub
  configuration. Keep historical check logs unchanged, including the URLs that
  were actually tested. The intended package repository is BlackThrive/searchlight
  and the documentation site is https://blackthrive.github.io/searchlight/.
* GitHub confirms that the authenticated maintainer is an active organization
  member and that members may create public repositories. The searchlight
  repository does not yet resolve. Create it for the requested original package,
  preserving the existing milestone history and using it for checks and docs.
* The maintainer explicitly requests no AI or Codex co-author attribution.
  Keep package authorship as Mustapha Wasseja (author and maintainer) and Black
  Thrive Global (copyright holder and funder); add no AI co-author commit trailers.
* The corrected metadata and README pass the local manual-inclusive as-CRAN
  check with zero errors, warnings and notes. Preserve the earlier uploaded
  archive separately before rebuilding. Publish the completed package with its
  existing six milestone commits intact as the new repository's initial main
  history; subsequent changes can be reviewed against that populated baseline.
* The first hosted checks exposed missing runner prerequisites: HTML Tidy on
  Linux/macOS, gettext headers for macOS R-devel, and roxygen2 for styler's
  documentation-example checks. Install these explicitly. The macOS dotCall64
  binary also fails to load an OpenMP symbol; rebuild the same CRAN release from
  source, linking CRAN R's supplied libomp runtime, and verify namespace loading.
  Keep all package tests enabled and retain these environment differences.
* Configure the documentation publisher's GitHub Actions build identity so its
  initial gh-pages commit succeeds. This is an automated deployment identity,
  not an AI author or co-author; package/source authorship remains unchanged.
* The Windows runner's TeX log contains a completed 33-page PDF with no LaTeX
  errors, but the external manual driver returns failure. Use R's documented
  texi2dvi emulation, which directly runs LaTeX and indexing until references
  resolve. This changes the driver, not the manual checks or their pass criteria.
* The emulation attempt did not resolve the Windows failure and introduced the
  same manual-driver symptom on macOS. Restore the default driver and add a
  direct Windows Rd2pdf preflight with retained intermediate files, so the
  underlying error is visible before installing the full dependency tree.
* Install the local package explicitly in the documentation workflow before
  rendering reference examples. Keep example acquisition offline and cap threads.
* The direct Windows manual preflight identifies the actual failure: makeindex
  is absent from TinyTeX. Install its TeX Live package along with the fonts,
  keeping PDF manual checks enabled on every OS and R version.
* Replace the inaccessible RAND reprint link with the author's verified
  university bibliography and retain the full paper citation and publisher-
  verified DOI. This is a bibliography link, not a claim to host the paper.
* The published pkgdown site passes HTTP checks for all 51 HTML pages. Local
  spelling, lint and all 16 package URLs pass after replacing the possessive
  surname in the citation label with "selected publications by Ridgeway".
* Seven full hosted checks now pass, including PDF manuals on all three Windows
  R versions. Linux/macOS R-devel dependencies and two R-hub platforms are still
  running; R-hub Windows passes with --no-manual. Keep their run URLs and exact
  scope in the release evidence. Rebuild and check the corrected source archive
  before sending it for another win-builder check; preserve the earlier result.
* Let an active check matrix finish before the next revision starts. R-devel
  compiles dependencies from source, and repeatedly cancelling it for evidence
  or documentation commits discards that installation work before caching.
* The corrected 1,635,822-byte source archive passed its own manual-inclusive
  as-CRAN check (0/0/0), maximum example 2.21 seconds, installed 3,039,622 bytes.
  Win-builder acknowledged that exact archive over HTTPS; its SHA-256 and
  receipt are retained separately from the earlier September 16 result. Await
  the maintainer's new result email and the outstanding hosted R-devel checks.
  No CRAN submission or release-ready assertion has been made.
* The remaining macOS R-devel job failed while building the terra dependency:
  gdal-config was missing. R-devel has no current CRAN macOS binaries, so install
  CRAN's matching GDAL and udunits system libraries (including their recursive
  dependencies) and expose the CRAN bin/pkg-config paths before R dependencies.
  Apply the same prerequisites and OpenMP rebuild to R-hub's macOS runner.
  The latest hosted quality workflow now passes after the citation correction.

## 2026-09-21: Corrected win-builder result verified

* The maintainer supplied the fresh result at
  https://win-builder.r-project.org/x5fBiE4ieQOI/. Its only NOTE is "New
  submission", explicitly permitted by section 8.2. There are no errors,
  warnings, incoming URL findings or README-file findings. All 392 assertions
  passed, with two intended CRAN skips; both manuals and all vignettes passed.
* Preserve the exact 1,635,822-byte uploaded archive, original logs and Windows
  binary before expiry. Verify the ZIP integrity and match the installed release
  evidence metadata against that archive. Record download and normalized-log
  hashes separately. Keep the original September 16 result unchanged.
* Eight of nine current CI jobs now pass, including Linux R-devel; R-hub Windows
  and Linux also pass. The macOS R-devel jobs remain in progress. Update the
  checklist and CRAN comments, but retain the pending release status until those
  checks complete. This result is a pre-submission check, not a CRAN submission.

## 2026-09-21: Match macOS Abseil headers and libraries

* All nine manual-inclusive hosted R/OS checks passed in run 35628215618.
  R-hub's Intel macOS runner separately failed loading s2 1.1.12: its compile
  command selected CRAN's Abseil 20250127 headers ahead of the bundled headers,
  then linked the bundled libraries, leaving DoIgnoreLeak unresolved.
* Install CRAN's absl system library and use s2 1.1.12's documented configure
  switch S2_FORCE_BUNDLED_ABSEIL=false on macOS. This keeps the headers and
  static libraries from the same CRAN toolchain. Retain every package check,
  and verify the correction with another R-hub macOS run. Bound each source
  build to two make jobs to reduce the long install. Package-install workers
  retain R-hub's Ncpus setting; pkgdepends reads that R option directly.
* Preserve normalized win-builder evidence with LF checkout attributes so its
  recorded hashes remain reproducible on Windows. The checked source archive
  and package implementation remain unchanged.
* The corrected workflow passed all nine jobs in run 35636569788. Preserve
  the complete check output and hashes for each platform under ci-2026-09-21.
  The original R-hub Linux/Windows artifacts also confirm Status: OK; preserve
  those logs separately and identify their --no-manual scope. The final Intel
  macOS R-hub run is still installing dependencies.
* Technical review confirmed 222 matching archive files (DESCRIPTION compared
  after build normalization), with changes limited to three existing evidence
  and decision/progress files. The archived source hash and all five preserved
  win-builder log hashes match. No analysis implementation or author-credit
  changes are required; retain the checked archive as the submission candidate.

## 2026-09-21: Final R-hub validation and release readiness

* R-hub Intel macOS run 35636576062 completed successfully. Both dependency
  installation and the OpenMP rebuild passed; the package's --no-manual
  --as-cran check reports Status: OK, with no errors, warnings or notes.
  Preserve its actual 00check.log and hash alongside the clean Linux/Windows
  results in BlackThrive-rhub.json. This closes the final external release gate.
* All nine full checks and Quality also pass on the release-evidence commit
  9fa60cc. Preserve the checked source archive without rebuilding it; its local
  and win-builder results apply to that exact SHA-256. Complete cran-comments
  and RELEASE_READY.md with the verified scope and results. The maintainer
  reviews the release pull request and submits to CRAN; no submission was made.
