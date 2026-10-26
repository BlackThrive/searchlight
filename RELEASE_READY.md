# searchlight 0.1.1 maintenance release

Status (2026-10-27): local checks and all nine hosted package checks pass;
final win-builder result pending. Additional CI dependency safeguards are added.
Version 0.1.1 has not been submitted to CRAN.
Version 0.1.0 was published on CRAN on 2026-09-30. CRAN has warned that
archival of suncalc on 2026-11-16 would also affect its strong reverse dependencies.

Version 0.1.1 removes suncalc from Imports and replaces its two solar-event calls
with an internal base-R calculator. No new dependency is introduced. The complete
BSD-2-Clause attribution for the original SunCalc.js equations is in
`inst/COPYRIGHTS`. Human authorship and the statistical models are unchanged.

Upstream released suncalc 0.5.4 on 2026-10-26 after the original status check.
CRAN lists that release, its NEWS addresses the reported moon-time error, and
all currently displayed CRAN checks are OK (mixed 0.5.3/0.5.4 during rollout).
The specific upstream fault has therefore received a published fix. No separate
withdrawal of the archival notice has been supplied. Version 0.1.1 still removes
the dependency to protect against future suncalc maintenance or archival issues.

Current validation:

- All 17,532 sunset/civil-dusk times agree exactly with frozen suncalc 0.5.3
  results, across six locations and every day of four years (including 2024).
- Both darkness designs and both twilight definitions retain their data,
  exclusions, coefficients and uncertainty intervals.
- All 17,532 reference solar times also match the new suncalc 0.5.4 exactly.
- The installed graph of 156 strong dependencies contains no suncalc. New CI
  safeguards reject direct/suggested or transitive strong dependencies on it;
  matrix and quality jobs explicitly run without it installed.
- Tests cover leap day, UK clock changes, host time zones, event boundaries
  and missing polar crossings. All 489 CRAN-mode assertions pass, with two
  intended skips. Full developer tests include those skipped cases and pass
  with 95.2071% line coverage, with suncalc unavailable.
- Building 0.1.1 succeeds with suncalc absent from the available R libraries.
- The exact final archive passes R CMD check --as-cran on Windows/R 4.5.2:
  0 errors, 0 warnings and 0 notes; PDF and HTML manuals included. Maximum
  example elapsed time is 0.86 seconds; installed size is 3,271,011 bytes.
  Local online incoming checks and the network clock probe were disabled.
- A fresh installation without suncalc reparses all 4,657 bundled records,
  exercises the analyses and safeguards, and writes the offline report.
- Style, lint and spelling are clean. Receipts and logs are under
  `data-raw/validation/solar-replacement/`.
- All nine hosted release/devel/oldrel checks on Windows, macOS and Linux pass,
  each with Status: OK and 489 passing assertions. The quality workflow passes.
  See `hosted-checks.json` for commit ebf02a8 and the run URLs. Follow-up CI
  verifies the newly added dependency guard; runtime package code is unchanged.
- Win-builder accepted the unchanged final archive on 2026-10-27 at about
  01:10 Nairobi time. The earlier queue refusals are retained as history.
  Verify the new email results link before recording a passing result;
  `win-builder-2026-10-27.json` currently records upload acknowledgment only.

Final source archive: `searchlight_0.1.1.tar.gz` (1,947,280 bytes).
SHA-256: `b485dec92ea71d11c9f2a823c84e45e6df3ccd6bfcbfb8ace2d00545b491a852`.
All 45 runtime and test R files in the archive match the working source;
the original 0.1.0 submitted archive remains unchanged.

Acceptance of 0.1.1 by CRAN is required for the published package itself to
become independent of suncalc. The upstream 0.5.4 fix reduces the immediate
concern, but does not change our dependency-removal plan. The earlier checks
below describe version 0.1.0 only and do not certify this maintenance release.

## Historical 0.1.0 release evidence (retained as recorded)

The September submission below was subsequently published on 2026-09-30.

The checked archive was uploaded through CRAN's official submission form on
2026-09-22 (submission ID 356075). CRAN acknowledged the submission action and
sent a confirmation email to the maintainer. It is awaiting the maintainer's
email confirmation before review; it has not been accepted or published.
Current win-builder and all nine CI checks pass. The archive is unchanged.

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
| R release, devel and oldrel on Linux, macOS and Windows | Current report implementation: all nine checks pass; 0 errors, warnings or notes; PDF/HTML manuals included | [CI run](https://github.com/BlackThrive/searchlight/actions/runs/35688724233), `inst/validation/BlackThrive-report-design-ci.json` and its nine saved logs |
| R-hub R-devel | Before the report redesign: Windows, Linux and Intel macOS pass; 0 errors, warnings or notes | `inst/validation/BlackThrive-rhub.json` and its three saved logs |
| Win-builder R-devel | Current archive: 0 errors, 0 warnings; only expected New submission NOTE | `inst/validation/BlackThrive-report-design-win-builder.json` and saved check/test/timing logs |
| Exact source archive, local R 4.5.2 | Redesigned archive: 0 errors, warnings or notes; PDF/HTML manuals included | `inst/validation/BlackThrive-report-design-source-check.json` and `.log` |
| Developer coverage | Current implementation: 95.0433%, above the 85% requirement | `inst/validation/BlackThrive-report-design-ci.json` and [Quality run](https://github.com/BlackThrive/searchlight/actions/runs/35688724230) |
| Lint, spelling, URLs | Current lint and spelling clean; 16 URLs previously verified and unchanged | `inst/validation/BlackThrive-report-design-demo.json`; historical `inst/validation/M5-quality.json` |
| Size and example runtime | Installed 3,200,250 bytes; extdata 810,818 bytes; maximum win-builder example 0.35 seconds; local outlier retained below | Exact-source check evidence |
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

Win-builder verification and the CRAN form submission are complete. The
maintainer must click the confirmation link sent to
mustapha.wasseja.mohammed@gmail.com. Do not upload another copy while this
submission is pending. See `inst/validation/BlackThrive-cran-submission-2026-09-22.json`.
The current `cran-comments.md` records the check information supplied in the
form. Evidence updates after the build do not change the submitted archive.
The previous source archive and original win-builder logs remain preserved under
`data-raw/work/win-builder-2026-09-21/`.
The release pull request remains available for maintainer review.
The local release wrapper's strict five-second elapsed-time gate failed on the
outlier above; R CMD check itself reports Status: OK. The isolated timing
rechecks pass. Fresh win-builder examples now pass with a maximum elapsed
time of 0.35 seconds; all nine current hosted checks also pass. This resolves
the external-check gate without suppressing the historical local outlier.
