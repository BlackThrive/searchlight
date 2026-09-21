## Development status

Not a CRAN submission. Version 0.1.0 is the intended first release. External
release gates remain pending and no RELEASE_READY.md has been produced.

## Test environments

Local: Windows 11 x64, R 4.5.2 (ucrt). This is not a substitute for the required
release/devel/oldrel checks on Linux, macOS and Windows. The nine-job workflow is
prepared; the BlackThrive/searchlight repository was created on 2026-09-21 and
its hosted checks are being verified.

M0-M4 local `--as-cran --no-manual` checks: 0 errors, 0 warnings, 0 notes.
M5 local `--as-cran`, including PDF and HTML manuals: 0 errors, 0 warnings,
0 notes; 392 assertions passed, with two CRAN-only skips. Local runs disable
online incoming checks and the network clock probe. Tests, examples
and precomputed vignettes require no network, and test resources are capped
at two threads. Logs and timings are retained in `inst/validation/`.

Full developer tests, including recovery and visual snapshots, passed in the
coverage run at 94.9358%. The slowest installed example took 2.25 seconds.
The checked installed package was 2,943,212 bytes; extdata was 810,818 bytes.
The completed studies include an
18-fit spatial pilot and 180 missingness simulations, with failed spatial
convergence retained and labelled. National validation reproduced all 3,096
monthly count cells exactly and 43 force ratios within 1.8e-15. Both batching
methods gave identical assignments and 116,551 aggregate count rows. Four
precomputed vignettes, the offline report and the local pkgdown site are built
and visually checked; the published fifteen-line quick start executes offline.

Win-builder: R Under development (2026-09-15 r90540 ucrt), Windows Server 2022
x64. The uploaded source archive completed with 0 errors, 0 warnings and 1 NOTE;
installation, examples, tests, vignettes and PDF/HTML manuals passed. The incoming
NOTE includes "New submission", three unavailable GitHub/site URLs, and two
README file links to excluded repository files (AGENTS.md and
RELEASE_CHECKLIST.md). The README links have since been replaced with plain
filename references; that edit has not been rechecked by win-builder. Logs and
the checked source hash are retained in `inst/validation/M5-win-builder.json`.

Spelling and lint are clean in the recorded local validation. R-hub's original
attempt returned Not Found for the placeholder repository. The maintainer has
since supplied the correct owner, BlackThrive, and the repository has been
created with corrected metadata. Fresh URL and hosted checks remain pending.
The RAND reprint URL previously returned 403 to the automated checker.

## Reverse dependencies

None (new package).
