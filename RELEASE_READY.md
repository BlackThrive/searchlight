# searchlight 0.1.0 release evidence

The report template was redesigned on 2026-09-22. The current archive passes
local checks and the fresh-install workflow; its fresh win-builder result
remains pending. No CRAN submission has been made.

## Checked source archive

Use the current `searchlight_0.1.0.tar.gz` (1,667,884 bytes).
SHA-256: `7087728ccd171841319149d8d1614b80a429dc5af5ffabac440280dfb1f213f5`.
It includes Sarah Hamed and Souci Frissa as coauthors and the redesigned report.
The installed demo reparses 4,657 events, recomputes the four-MSOA analysis,
exercises diagnostics and writes the actual package HTML report. All ten exported
result CSVs are byte-identical before and after the presentation changes.
The report has summary cards, responsive navigation, readable tables and
expandable audit details; all analytical evidence remains available offline.

The previous report archive is preserved under `data-raw/work/report-before-redesign/`;
earlier archives remain under `data-raw/work/authorship-2026-09-22/` and
`data-raw/work/win-builder-2026-09-21/`. Their receipts describe those earlier
archive hashes, not the current candidate.

## Validation

| Requirement | Result | Evidence |
| --- | --- | --- |
| R release, devel and oldrel on Linux, macOS and Windows | Before the report redesign: all nine checks pass; 0 errors, warnings or notes; PDF/HTML manuals included | [CI run](https://github.com/BlackThrive/searchlight/actions/runs/35636569788), `inst/validation/BlackThrive-ci-matrix.json` and its nine saved logs |
| R-hub R-devel | Before the report redesign: Windows, Linux and Intel macOS pass; 0 errors, warnings or notes | `inst/validation/BlackThrive-rhub.json` and its three saved logs |
| Win-builder R-devel | Earlier archive: 0 errors, 0 warnings; only permitted New submission NOTE; redesigned-archive result pending | Historical `inst/validation/BlackThrive-win-builder.json`; current `inst/validation/BlackThrive-report-design-win-builder.json` |
| Exact source archive, local R 4.5.2 | Redesigned archive: 0 errors, warnings or notes; PDF/HTML manuals included | `inst/validation/BlackThrive-report-design-source-check.json` and `.log` |
| Developer coverage | Before the redesign: 94.9358%, above the 85% requirement | `inst/validation/M5-coverage.json` and hosted Quality workflow |
| Lint, spelling, URLs | Current lint and spelling clean; 16 URLs previously verified and unchanged | `inst/validation/BlackThrive-report-design-demo.json`; historical `inst/validation/M5-quality.json` |
| Size and example runtime | Installed 3,200,250 bytes; extdata 810,818 bytes; maximum local example 16.28 seconds | Exact-source check evidence |
| Offline report and vignettes | End-to-end report and four precomputed vignettes rendered and inspected | `RELEASE_CHECKLIST.md`, `inst/validation/` |
| Statistical validation | Spatial recovery, 180 missingness lattices, national reproduction and timing benchmark complete | Committed scripts/results under `inst/scripts/` and `inst/validation/` |
| Public documentation | 51 HTML pages verified HTTP 200 | [Published site](https://blackthrive.github.io/searchlight/), `inst/validation/BlackThrive-live-site.json` |
| Release review | Build changes, metadata and preserved archive technically reviewed | [Pull request 1](https://github.com/BlackThrive/searchlight/pull/1), `inst/NOTES/decisions.md` |

R-hub uses `--no-manual --as-cran`; PDF and HTML manuals are checked separately
on all nine CI environments and by win-builder. Local checks disable online
incoming checks and the network clock probe; the fresh win-builder check supplies the updated online
incoming result. Tests, examples and vignettes use offline data. The two CRAN
skips are covered by the full developer validation run.

The initial check recorded a 16.28-second elapsed-time outlier for sl_read_records (0.73 CPU seconds). The identical example from the same installed archive passed isolated reruns in 0.53 and 0.17 seconds. The original result and both reruns are retained.

See `inst/validation/BlackThrive-report-design-example-timings.json`.

## Maintainer handoff

Maintainer/author: Mustapha Wasseja. Coauthors: Sarah Hamed and Souci Frissa.
Copyright holder/funder: Black Thrive Global.
Repository: https://github.com/BlackThrive/searchlight. Package metadata and
source commits retain the agreed human authorship.

Inspect the fresh win-builder result for the redesigned archive before submitting
it with `cran-comments.md` through CRAN's maintainer submission process.
The previous source archive and original win-builder logs remain preserved under
`data-raw/work/win-builder-2026-09-21/`.
The release pull request remains available for maintainer review.
The local release wrapper's strict five-second elapsed-time gate failed on the
outlier above; R CMD check itself reports Status: OK. The isolated timing
rechecks pass. Fresh external checks remain required before submission.
