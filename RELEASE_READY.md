# searchlight 0.1.0 release evidence

Prepared for maintainer submission to CRAN. No CRAN submission has been made.
The 2026-09-22 installed-user demonstration found and fixed a report number-formatting
issue. The current archive passes local checks and the fresh-install workflow;
its fresh win-builder result remains pending.

## Checked source archive

Use the current `searchlight_0.1.0.tar.gz` (1,659,470 bytes).
SHA-256: `6e08bf8f5f325d9b5624a2f1fd3c9dcd39e4f9d8c06c1455be5f0c641115703a`.
It includes Sarah Hamed and Souci Frissa as coauthors and the report display fix.
The installed demo reparses 4,657 events, recomputes the four-MSOA analysis,
exercises diagnostics and writes the actual package HTML report. All ten exported
result CSVs are byte-identical before and after the formatting correction.

The earlier coauthor archive is preserved under `data-raw/work/authorship-2026-09-22/`;
the September 21 archive is under `data-raw/work/win-builder-2026-09-21/`.
Their receipts describe those earlier archive hashes, not the current candidate.

## Validation

| Requirement | Result | Evidence |
| --- | --- | --- |
| R release, devel and oldrel on Linux, macOS and Windows | Before the display fix: all nine checks pass; 0 errors, warnings or notes; PDF/HTML manuals included | [CI run](https://github.com/BlackThrive/searchlight/actions/runs/35636569788), `inst/validation/BlackThrive-ci-matrix.json` and its nine saved logs |
| R-hub R-devel | Before the display fix: Windows, Linux and Intel macOS pass; 0 errors, warnings or notes | `inst/validation/BlackThrive-rhub.json` and its three saved logs |
| Win-builder R-devel | Earlier archive: 0 errors, 0 warnings; only permitted New submission NOTE; fresh corrected-archive result pending | Historical `inst/validation/BlackThrive-win-builder.json`; current `inst/validation/BlackThrive-demo-win-builder.json` |
| Exact source archive, local R 4.5.2 | Corrected archive: 0 errors, warnings or notes; PDF/HTML manuals included | `inst/validation/BlackThrive-demo-source-check.json` and `.log` |
| Developer coverage | 94.9358%, above the 85% requirement | `inst/validation/M5-coverage.json` and hosted Quality workflow |
| Lint, spelling, URLs | Clean; all 16 package URLs pass | `inst/validation/M5-quality.json` |
| Size and example runtime | Installed 3,173,589 bytes; extdata 810,818 bytes; maximum local example 0.65 seconds | Exact-source check evidence; previous win-builder maximum 0.36 seconds |
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

Inspect the fresh win-builder result for the corrected archive before submitting
it with `cran-comments.md` through CRAN's maintainer submission process.
The previous source archive and original win-builder logs remain preserved under
`data-raw/work/win-builder-2026-09-21/`.
The release pull request remains available for maintainer review.
