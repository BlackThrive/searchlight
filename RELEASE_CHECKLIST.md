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
- [x] Examples below five seconds (local maximum 2.21); installed 3.04 MB, extdata 0.81 MB
- [x] Final spelling check clean
- [x] URL check clean (2026-09-21, all 16 checked URLs)
- [x] Local pkgdown site built and inspected; 51 pages have valid local links
- [x] Win-builder R-devel upload acknowledged over HTTPS; receipt and hash saved
- [x] Win-builder R-devel result retrieved: 0 errors, 0 warnings, 1 incoming NOTE
- [x] Corrected archive rebuilt, checked locally (0/0/0), and accepted by win-builder
- [x] Win-builder incoming URL issues resolved; corrected archive has only New submission NOTE
- [ ] Full R/OS CI matrix and rhub verified
- [x] pkgdown deployed; all 51 published HTML pages return HTTP 200
- [x] Hosted release pull request technically reviewed; package implementation and author credits unchanged

The maintainer corrected the GitHub owner to BlackThrive on 2026-09-21.
The public repository https://github.com/BlackThrive/searchlight has been created
and package, issue-tracker, pkgdown and R-hub URLs now use that owner. Source and
documentation are published. Release fixes are in pull request 1. All nine
manual-inclusive CI jobs passed in run 35636569788 after the Abseil fix (the
earlier runs 35628215618 and 35634359155 also passed). R-hub Windows and Linux
R-devel pass with --no-manual --as-cran. Its Intel macOS runner exposed an s2
Abseil header/library mismatch. The workflows now select matching CRAN system
libraries; R-hub macOS run 35636576062 is verifying that fix on Intel macOS.
BlackThrive-ci-matrix.json and ci-2026-09-21 contain all nine clean check logs
and their hashes. BlackThrive-rhub.json and rhub-2026-09-21 preserve the clean
R-hub Linux/Windows logs, with their --no-manual scope stated explicitly.
See M5-external-checks.json for run URLs
and the status snapshot. The earlier R-hub attempts and failed runner checks are
retained as historical evidence, not treated as passing checks.

The RAND reprint server returned HTTP 403 to automated checks. Its paper citation
now retains the verified DOI and links to the author's university bibliography.
Fresh URL checking, spelling and lint all pass. The hosted quality workflow also
passes after the citation correction. BlackThrive-live-site.json records
the deployed site revision and successful HTTP checks for all 51 HTML pages.

Win-builder rechecked the corrected 1,635,822-byte archive on R-devel
(2026-09-20 r90574 ucrt), Windows Server 2022: 0 errors, 0 warnings and 1 NOTE,
solely "New submission". The former URL and README-file issues are resolved.
All 392 assertions passed, with two intended CRAN skips. Examples, vignettes
and PDF/HTML manuals passed; the longest example took 0.36 seconds.
This satisfies the win-builder gate and the permitted new-submission exception.

The exact source archive, Windows binary and original logs have been preserved.
BlackThrive-win-builder.json records the result URL, hashes and normalized logs
under inst/validation/win-builder-2026-09-21. BlackThrive-source-check.json records
the same archive's local manual-inclusive check (0/0/0). The earlier result is
retained separately in M5-win-builder.json. The checked archive is unchanged.
An archive comparison verified 222 matching files, including normalized
DESCRIPTION fields; only three existing decision/progress/evidence files differ.
The review found no remaining implementation or authorship issues. External
validation remains pending; this technical review is not a maintainer approval.

No release-ready assertion is made until every required check has evidence.
