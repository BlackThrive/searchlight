# searchlight 0.1.0 release evidence

Prepared for maintainer submission to CRAN. No CRAN submission has been made.
All required technical release checks passed on 2026-09-21. The 2026-09-22
authorship update adds Sarah Hamed and Souci Frissa. Its rebuilt archive is
locally checked with 0 errors, warnings or notes; its fresh win-builder result
is pending. The earlier win-builder result applies to the earlier archive.

## Checked source archive

The current `searchlight_0.1.0.tar.gz` (1,657,292 bytes) includes all three authors.
SHA-256: `32b45a2ecf72c4e627e472dbf83bdd3c92cc0af1fe3618aabfa96dd88302cfdd`.
An archive comparison confirms 83 implementation, test, data, validation-script
and vignette-source files are unchanged. The package manual adds the coauthors.
Current check evidence is recorded in `BlackThrive-authorship-*.json` below.

The previously checked archive remains preserved under
`data-raw/work/win-builder-2026-09-21/` (SHA-256
`4a57eee0d39888ff514f87cb7d0adcf3e12bea8a6809e0bfdbc725edc5006a45`).
It passed both local and win-builder checks but contains the previous author list.

## Validation

| Requirement | Result | Evidence |
| --- | --- | --- |
| R release, devel and oldrel on Linux, macOS and Windows | All nine checks pass; 0 errors, warnings or notes; PDF/HTML manuals included | [CI run](https://github.com/BlackThrive/searchlight/actions/runs/35636569788), `inst/validation/BlackThrive-ci-matrix.json` and its nine saved logs |
| R-hub R-devel | Windows, Linux and Intel macOS pass; 0 errors, warnings or notes | `inst/validation/BlackThrive-rhub.json` and its three saved logs |
| Win-builder R-devel | Earlier archive: 0 errors, 0 warnings; only permitted New submission NOTE; fresh authorship-archive result pending | Historical `inst/validation/BlackThrive-win-builder.json`; current `inst/validation/BlackThrive-authorship-win-builder.json` |
| Exact source archive, local R 4.5.2 | Authorship archive: 0 errors, warnings or notes; PDF/HTML manuals included | `inst/validation/BlackThrive-authorship-source-check.json` and `.log` |
| Developer coverage | 94.9358%, above the 85% requirement | `inst/validation/M5-coverage.json` and hosted Quality workflow |
| Lint, spelling, URLs | Clean; all 16 package URLs pass | `inst/validation/M5-quality.json` |
| Size and example runtime | Installed 3,165,187 bytes; extdata 810,818 bytes; maximum local example 1.47 seconds | Exact-source check evidence; previous win-builder maximum 0.36 seconds |
| Offline report and vignettes | End-to-end report and four precomputed vignettes rendered and inspected | `RELEASE_CHECKLIST.md`, `inst/validation/` |
| Statistical validation | Spatial recovery, 180 missingness lattices, national reproduction and timing benchmark complete | Committed scripts/results under `inst/scripts/` and `inst/validation/` |
| Public documentation | 51 HTML pages verified HTTP 200 | [Published site](https://blackthrive.github.io/searchlight/), `inst/validation/BlackThrive-live-site.json` |
| Release review | Build changes, metadata and preserved archive technically reviewed | [Pull request 1](https://github.com/BlackThrive/searchlight/pull/1), `inst/NOTES/decisions.md` |

R-hub uses `--no-manual --as-cran`; PDF and HTML manuals are checked separately
on all nine CI environments and by win-builder. Local checks disable online
incoming checks and the network clock probe; the fresh win-builder check supplies the updated online
incoming result. Tests, examples and vignettes use offline data. The two CRAN
skips are covered by the full developer validation run.

## Maintainer handoff

Maintainer/author: Mustapha Wasseja. Coauthors: Sarah Hamed and Souci Frissa.
Copyright holder/funder: Black Thrive Global.
Repository: https://github.com/BlackThrive/searchlight. Package metadata and
source commits retain the agreed human authorship.

Inspect the fresh win-builder result for the authorship archive before submitting
it with `cran-comments.md` through CRAN's maintainer submission process.
The previous source archive and original win-builder logs remain preserved under
`data-raw/work/win-builder-2026-09-21/`.
The release pull request remains available for maintainer review.
