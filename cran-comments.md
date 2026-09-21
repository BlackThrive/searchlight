## Development status

Not a CRAN submission. Version 0.1.0 is the intended first release. External
release gates remain pending and no RELEASE_READY.md has been produced.

## Test environments

Local: Windows 11 x64, R 4.5.2 (ucrt). This is not a substitute for the required
release/devel/oldrel checks on Linux, macOS and Windows. The nine-job workflow is
running in BlackThrive/searchlight, published on 2026-09-21. Seven jobs pass:
Windows release/devel/oldrel, Linux release/oldrel and macOS release/oldrel.
macOS R-devel failed to build terra because its runner lacked gdal-config;
matching CRAN system libraries have been added and replacement checks queued.
Linux R-devel is still installing dependencies. All nine jobs
include PDF manuals and treat check notes as failures. R-hub Windows R-devel
passes --no-manual --as-cran; its Linux/macOS jobs are still running.

M0-M4 local `--as-cran --no-manual` checks: 0 errors, 0 warnings, 0 notes.
M5 local `--as-cran`, including PDF and HTML manuals: 0 errors, 0 warnings,
0 notes; 392 assertions passed, with two CRAN-only skips. Local runs disable
online incoming checks and the network clock probe. Tests, examples
and precomputed vignettes require no network, and test resources are capped
at two threads. Logs and timings are retained in `inst/validation/`.

The rebuilt 2026-09-21 source archive also passed a manual-inclusive local
--as-cran check with 0 errors, 0 warnings and 0 notes. Its hash and check log are
in BlackThrive-source-check.json and BlackThrive-source-check.log. The same
online incoming and clock exceptions apply. Its slowest example took 2.21
seconds and its installed size was 3,039,622 bytes; extdata remains 810,818 bytes.

Full developer tests, including recovery and visual snapshots, passed in the
coverage run at 94.9358%.
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
filename references, and all current package URLs pass the URL checker. A fresh
win-builder result for the corrected archive is still required. Win-builder
acknowledged the new 1,635,822-byte archive on 2026-09-21 and will email the
maintainer; the receipt and hash are in BlackThrive-win-builder.json. Logs and
the checked source hash are retained in `inst/validation/M5-win-builder.json`.

Spelling, lint and all 16 checked URLs are clean in the 2026-09-21 local
validation. R-hub's original attempt returned Not Found for the placeholder
repository; the corrected workflow is now running. The public pkgdown site is
deployed at https://blackthrive.github.io/searchlight/ and all 51 HTML pages
return HTTP 200. The RAND reprint server's automated HTTP 403 was resolved by
retaining the verified paper DOI and linking to the author's university
bibliography. Current run URLs and scope are in M5-external-checks.json.

## Reverse dependencies

None (new package).
