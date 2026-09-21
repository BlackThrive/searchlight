## Development status

Not a CRAN submission. Version 0.1.0 is the intended first release. External
release gates remain pending and no RELEASE_READY.md has been produced.

## Test environments

Local: Windows 11 x64, R 4.5.2 (ucrt). This is not a substitute for the required
release/devel/oldrel checks on Linux, macOS and Windows. The nine-job workflow is
running in BlackThrive/searchlight, published on 2026-09-21. All nine jobs passed
in run 35636569788: Windows, Linux and macOS release/devel/oldrel.
All nine jobs include PDF manuals and treat check notes as failures. R-hub
Windows and Linux R-devel pass --no-manual --as-cran. Its Intel macOS runner
exposed an s2 Abseil header/library mismatch; matching CRAN system libraries
are now selected, with the replacement macOS check in progress.

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

Win-builder: R Under development (2026-09-20 r90574 ucrt), Windows Server 2022
x64. The corrected source archive completed with 0 errors, 0 warnings and 1 NOTE:
"New submission". There are no remaining incoming URL or README-file findings.
All 392 assertions passed, with two intended CRAN skips; installation, examples,
vignettes and PDF/HTML manuals passed. The maximum example time was 0.36 seconds.
The source archive hash and verified result are in BlackThrive-win-builder.json;
logs are retained under inst/validation/win-builder-2026-09-21. The earlier
September 16 result is preserved separately as historical evidence.

Spelling, lint and all 16 checked URLs are clean in the 2026-09-21 local
validation. R-hub's original attempt returned Not Found for the placeholder
repository; the corrected workflow is now running. The public pkgdown site is
deployed at https://blackthrive.github.io/searchlight/ and all 51 HTML pages
return HTTP 200. The RAND reprint server's automated HTTP 403 was resolved by
retaining the verified paper DOI and linking to the author's university
bibliography. Current run URLs and scope are in M5-external-checks.json.

## Reverse dependencies

None (new package).
