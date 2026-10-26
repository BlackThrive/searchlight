## Maintenance update: searchlight 0.1.1

This update addresses the CRAN notification that suncalc and its strong reverse
dependencies are scheduled for archival on 2026-11-16. It removes suncalc from
Imports. Only sunset and civil-dusk calculations are replaced, using internal
base-R equations adapted from SunCalc.js 1.9.0, with the complete BSD-2-Clause
notice included in inst/COPYRIGHTS. No replacement dependency is introduced.

Regression tests compare 17,532 solar-event times with frozen outputs from
suncalc 0.5.3: all match exactly at whole-second resolution. Both darkness
designs and both twilight definitions retain the same classifications,
exclusion audits, coefficients and intervals. Tests also cover leap day,
UK clock changes, host time-zone independence and unavailable polar events.

## Current checks (2026-10-26)

The exact source archive passes R CMD check --as-cran on Windows 11 x64,
R 4.5.2, with 0 errors, 0 warnings and 0 notes, including PDF/HTML manuals.
All 489 CRAN-mode assertions pass, with two intended CRAN skips. The full
developer suite includes spatial recovery and visual snapshots and has
95.2071% line coverage. Style, lint and spelling checks are clean.

Build, check, installation and developer coverage were run with suncalc
unavailable. A fresh installation reparses 4,657 bundled records and produces
the offline report. Maximum example elapsed time is 0.86 seconds; installed
size is 3,271,011 bytes.

Local online incoming checks and the network clock probe were disabled.
Hosted and final win-builder checks remain pending; record their verified
results here before submitting to CRAN. The earlier win-builder upload
is still processing and has temporarily blocked upload of the final archive.

Tests, examples and the four precomputed vignettes run offline. Resources
are capped at two threads. The package's statistical models, public interface
and agreed human authorship are unchanged.
