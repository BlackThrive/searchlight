# Version 0.1.1 dependency replacement

These developer release receipts are excluded from the package by `.Rbuildignore`.
The current artifact is identified by `source-artifact.json`; only receipts with
the same source hash describe that exact archive.

## Scope and upstream status

On 2026-10-26, CRAN's suncalc check page still reports an R-devel Windows failure
in a moon-time example. The maintainer's CRAN email gives an archival deadline of
2026-11-16 for suncalc and its strong reverse dependencies.

- CRAN: https://cran.r-project.org/web/checks/check_results_suncalc.html
- Upstream: https://github.com/datastorm-open/suncalc
- Latest public commit observed: `ffd9e6af575c3e8370ed1a877deedda5e1eea7e5`,
  dated 2026-07-15, version 0.5.3. No public fix announcement was found in the
  inspected commits, issues or pull requests. No maintainer was contacted.

The published searchlight 0.1.0 archive's 24 R files match baseline revision
`03279ea`. The maintenance branch starts there, retaining the published report
and coauthor metadata. The two calls in `R/infer-veil.R` now use the internal
`sl_solar_times()` helper. There are no new package dependencies.

## Numerical reference

`tests/testthat/fixtures/solar-reference.rds` was generated before replacing the
calls, by executing the unmodified suncalc 0.5.3 package as a black box. It stores
8,766 location-days (six locations, every day of 2014, 2024, 2026 and 2030), annual
windows, and four complete darkness analyses. All 17,532 event times agree at
whole-second resolution. Model comparisons include retained design data, audit
steps, coefficients and uncertainty intervals; only run-specific contract
creation timestamps are excluded.

The original SunCalc.js 1.9.0 equations were adapted under BSD-2-Clause;
`inst/COPYRIGHTS` retains the complete notice. No R suncalc source was copied.
The frozen fixture is included in tests; its developer generator is excluded
from the archive and explicitly requires the original 0.1.0 baseline.

## Check conditions

The package is built, installed, checked and exercised with an isolated R library
that excludes both suncalc and any pre-existing searchlight installation. The
dependency isolation is asserted in the check and coverage drivers. Manual,
vignette, example and test checks are enabled. Only local online incoming checks
and the network clock probe are disabled; external verification remains separate.

The first check ran in Dropbox and encountered a Windows file-lock warning during
the final installation rename. Its receipt is retained in
`earlier-dropbox-check.json`. A subsequent check outside Dropbox passed, as shown
in `pre-format-source-check.json`; its archive predates the final line wrapping
and spelling dictionary entries and is not the final artifact.

`quality.json` records clean style, lint and spelling checks against a clean copy
of tracked and non-ignored files. This avoids traversing local dependency caches.
`artifact-audit.json` verifies all 45 runtime/test R files against the source
archive, absence of suncalc namespace calls/imports, and the included BSD notice.

`installed-demo.json` covers a fresh installation, parsing all 4,657 sample
records, four-area rate/sensitivity analyses, safeguards, four installed
vignettes and the offline HTML report. External checks and submission status
are tracked in `RELEASE_READY.md`; an upload acknowledgment is not a check result.
