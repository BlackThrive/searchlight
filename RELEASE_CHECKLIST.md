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
- [x] URL check clean (2026-09-21, all 16 checked URLs)
- [x] Local pkgdown site built and inspected; 51 pages have valid local links
- [x] Win-builder R-devel upload acknowledged over HTTPS; receipt and hash saved
- [x] Win-builder R-devel result retrieved: 0 errors, 0 warnings, 1 incoming NOTE
- [x] Corrected archive rebuilt, checked locally (0/0/0), and accepted by win-builder
- [ ] Win-builder incoming URL issues resolved and corrected archive rechecked
- [ ] Full R/OS CI matrix and rhub verified
- [x] pkgdown deployed; all 51 published HTML pages return HTTP 200
- [ ] Hosted release pull request reviewed

The maintainer corrected the GitHub owner to BlackThrive on 2026-09-21.
The public repository https://github.com/BlackThrive/searchlight has been created
and package, issue-tracker, pkgdown and R-hub URLs now use that owner. Source and
documentation are published. Release fixes are in pull request 1. Seven of the
nine manual-inclusive CI jobs pass; Linux/macOS R-devel dependency installation
remains in progress. R-hub Windows R-devel passes with --no-manual --as-cran;
its Linux/macOS jobs remain in progress. See M5-external-checks.json for run URLs
and the status snapshot. The earlier R-hub attempts and failed runner checks are
retained as historical evidence, not treated as passing checks.

The RAND reprint server returned HTTP 403 to automated checks. Its paper citation
now retains the verified DOI and links to the author's university bibliography.
Fresh URL checking, spelling and lint all pass. BlackThrive-live-site.json records
the deployed site revision and successful HTTP checks for all 51 HTML pages.

Win-builder checked version 0.1.0 on R-devel (2026-09-15 r90540 ucrt), Windows
Server 2022, with 0 errors, 0 warnings and 1 NOTE. Installation, tests, examples,
vignettes and PDF/HTML manuals passed. The incoming NOTE groups the expected
new-submission notice, three URLs using the old placeholder owner, and README
file links to AGENTS.md and RELEASE_CHECKLIST.md, which are excluded from the
source archive. The two README links are now plain filename references and all
current package URLs pass. The corrected archive passed a local manual-inclusive
check (0/0/0) and win-builder acknowledged its 1,635,822-byte upload on 2026-09-21.
Its SHA-256 is recorded in BlackThrive-source-check.json and
BlackThrive-win-builder.json. The fresh win-builder result is pending delivery
to the maintainer email. The exact previously checked source
hash and preserved logs are recorded in `inst/validation/M5-win-builder.json`.

No release-ready assertion is made until every required check has evidence.
