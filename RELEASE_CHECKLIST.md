# Release evidence

- [x] M0: skeleton and clean local R CMD check (see `inst/validation/M0-check.log`)
- [x] M1: archive ingestion, revision selection and contract fixtures
- [x] M2: verified geography, population, coverage and quality
- [x] M3: known-answer rates and sensitivity, rendered vignette
- [x] M4: inference, spatial recovery evidence, outcome and darkness tests
- [x] Offline sample HTML report rendered and inspected on desktop and mobile
- [x] Missingness study: 180 lattices; all 4,500 realised ratios inside bounds
- [x] Independent national CSV/Census reference for 43 territorial forces
- [x] Actual package ingestion and ratios match that independent reference
- [x] National twelve-month timing comparison complete and reported in README
- [x] Four final precomputed vignettes rendered and inspected
- [x] Published fifteen-line quick start executes successfully offline
- [x] Final coverage at least 85%: 94.9358%, including full recovery and snapshots
- [x] Package lint clean after report and missing-submission fixes
- [x] Final local M5 as-CRAN check: 0 errors/warnings/notes, PDF/HTML manuals included
- [x] Examples below five seconds (maximum 2.25); installed 2.94 MB, extdata 0.81 MB
- [x] Final spelling check clean
- [ ] URL check clean
- [x] Local pkgdown site built and inspected; 51 pages have valid local links
- [x] Win-builder R-devel upload acknowledged over HTTPS; receipt and hash saved
- [x] Win-builder R-devel result retrieved: 0 errors, 0 warnings, 1 incoming NOTE
- [ ] Win-builder incoming URL issues resolved and corrected archive rechecked
- [ ] Full R/OS CI matrix and rhub verified
- [ ] pkgdown deployed and milestone pull requests reviewed

The maintainer corrected the GitHub owner to BlackThrive on 2026-09-21.
The public repository https://github.com/BlackThrive/searchlight has been created
and package, issue-tracker, pkgdown and R-hub URLs now use that owner. Publication,
remote CI, R-hub and documentation deployment are being verified. The earlier
R-hub attempt returned Not Found for the old placeholder repository. URL checking
also encountered a 403 response from the RAND paper server; its source was
verified separately and the automatic failure is not treated as a pass.

Win-builder checked version 0.1.0 on R-devel (2026-09-15 r90540 ucrt), Windows
Server 2022, with 0 errors, 0 warnings and 1 NOTE. Installation, tests, examples,
vignettes and PDF/HTML manuals passed. The incoming NOTE groups the expected
new-submission notice, three URLs using the old placeholder owner, and README
file links to AGENTS.md and RELEASE_CHECKLIST.md, which are excluded from the
source archive. The two README links are now plain filename references; the
corrected README has not been rechecked by win-builder. The exact checked source
hash and preserved logs are recorded in `inst/validation/M5-win-builder.json`.

No release-ready assertion is made until every required check has evidence.
