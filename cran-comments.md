## Development status

Not a CRAN submission. Version 0.1.0 is the intended first release. External
release gates remain pending and no RELEASE_READY.md has been produced.

## Test environments

Local: Windows 11 x64, R 4.5.2 (ucrt). This is not a substitute for the required
release/devel/oldrel checks on Linux, macOS and Windows. The nine-job workflow is
prepared, but the specified GitHub repository is unavailable.

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

Spelling and lint are clean. R-hub was attempted and returned Not Found for the
specified repository. Win-builder R-devel acknowledged the HTTPS source upload;
its emailed check result remains to be verified. The required
repository, issue tracker and website URLs returned 404; the RAND reprint URL
returned 403 to the automated checker. These failures have not been hidden.

## Reverse dependencies

None (new package).
