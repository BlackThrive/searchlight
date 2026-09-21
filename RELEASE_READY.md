# searchlight 0.1.0 release evidence

Prepared for maintainer submission to CRAN. No CRAN submission has been made.
All required technical release checks passed on 2026-09-21.

## Checked source archive

Use the preserved `searchlight_0.1.0.tar.gz` (1,635,822 bytes).
SHA-256: `4a57eee0d39888ff514f87cb7d0adcf3e12bea8a6809e0bfdbc725edc5006a45`.
The same archive passed the local manual-inclusive check and win-builder.
Its package implementation, tests, vignettes and DESCRIPTION fields match the
release branch. Subsequent changes concern hosted build prerequisites and
release evidence. Rebuilding would create a different archive.

## Validation

| Requirement | Result | Evidence |
| --- | --- | --- |
| R release, devel and oldrel on Linux, macOS and Windows | All nine checks pass; 0 errors, warnings or notes; PDF/HTML manuals included | [CI run](https://github.com/BlackThrive/searchlight/actions/runs/35636569788), `inst/validation/BlackThrive-ci-matrix.json` and its nine saved logs |
| R-hub R-devel | Windows, Linux and Intel macOS pass; 0 errors, warnings or notes | `inst/validation/BlackThrive-rhub.json` and its three saved logs |
| Win-builder R-devel | 0 errors, 0 warnings; only permitted New submission NOTE; 392 assertions pass | `inst/validation/BlackThrive-win-builder.json`, preserved logs in `inst/validation/win-builder-2026-09-21/` |
| Exact source archive, local R 4.5.2 | 0 errors, warnings or notes; PDF/HTML manuals included | `inst/validation/BlackThrive-source-check.json` and `.log` |
| Developer coverage | 94.9358%, above the 85% requirement | `inst/validation/M5-coverage.json` and hosted Quality workflow |
| Lint, spelling, URLs | Clean; all 16 package URLs pass | `inst/validation/M5-quality.json` |
| Size and example runtime | Installed 3,039,622 bytes; extdata 810,818 bytes; maximum local example 2.21 seconds | Exact-source check evidence; win-builder maximum 0.36 seconds |
| Offline report and vignettes | End-to-end report and four precomputed vignettes rendered and inspected | `RELEASE_CHECKLIST.md`, `inst/validation/` |
| Statistical validation | Spatial recovery, 180 missingness lattices, national reproduction and timing benchmark complete | Committed scripts/results under `inst/scripts/` and `inst/validation/` |
| Public documentation | 51 HTML pages verified HTTP 200 | [Published site](https://blackthrive.github.io/searchlight/), `inst/validation/BlackThrive-live-site.json` |
| Release review | Build changes, metadata and preserved archive technically reviewed | [Pull request 1](https://github.com/BlackThrive/searchlight/pull/1), `inst/NOTES/decisions.md` |

R-hub uses `--no-manual --as-cran`; PDF and HTML manuals are checked separately
on all nine CI environments and by win-builder. Local checks disable online
incoming checks and the network clock probe; win-builder supplies the online
incoming result. Tests, examples and vignettes use offline data. The two CRAN
skips are covered by the full developer validation run.

## Maintainer handoff

Maintainer/author: Mustapha Wasseja. Copyright holder/funder: Black Thrive Global.
Repository: https://github.com/BlackThrive/searchlight. Package metadata and
source commits retain the agreed human authorship.

Submit the checked source archive with the current `cran-comments.md` through
CRAN's maintainer submission process. The source archive and original
win-builder logs are also preserved under `data-raw/work/win-builder-2026-09-21/`.
The release pull request remains available for maintainer review.
