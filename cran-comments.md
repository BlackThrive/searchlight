## First submission

This is the first CRAN submission of searchlight 0.1.0. The previous archive's win-builder NOTE
is "New submission". There are no errors, warnings or remaining incoming URL
or README-file findings. The package has no reverse dependencies.

## Test environments and results

* Linux, macOS and Windows: R 4.6.1, R-devel (2026-09-20 r90574), and R 4.5.3.
  All nine --as-cran checks pass with 0 errors, 0 warnings and 0 notes. PDF and
  HTML manuals are included. The macOS matrix uses ARM64 runners.
* R-hub: Linux, Windows and Intel macOS R-devel. All three --no-manual --as-cran
  checks pass with 0 errors, 0 warnings and 0 notes. The Intel macOS environment
  is macOS Sequoia 15.7.9, x86_64-apple-darwin20.
* Win-builder: R-devel (2026-09-20 r90574 ucrt), Windows Server 2022 x64.
  The archive checked on 2026-09-21 has 0 errors, 0 warnings and 1 NOTE, solely
  "New submission". PDF/HTML manuals, examples and vignettes pass.
* Local: Windows 11 x64, R 4.5.2. The previous source archive passes --as-cran,
  including PDF/HTML manuals, with 0 errors, 0 warnings and 0 notes. Local
  online incoming checks and the network clock probe are disabled; win-builder
  provides the online incoming result.

The full matrix and hosted quality checks pass on commit 9fa60cc. R-hub macOS
passes in run 35636576062; its earlier Windows/Linux results are retained.
Run URLs, complete check logs and hashes are under inst/validation/.

## Authorship update, 2026-09-22

Sarah Hamed and Souci Frissa were added as authors. Mustapha Wasseja remains
the maintainer. The source archive was rebuilt with the updated metadata and
package manual; analysis code, tests, data and vignette sources are unchanged.
The earlier platform results above predate this metadata change. The rebuilt
archive passes the local --as-cran check with 0 errors, warnings or notes,
including both manuals. Installed size is 3,165,187 bytes;
the longest example takes 1.47 seconds. A fresh
win-builder check has been requested; its result must be recorded before
submission. The current archive hash and check evidence are in RELEASE_READY.md.

## Installed-user verification and report formatting, 2026-09-22

A fresh installation of the current archive reparsed all 4,657 bundled events,
recomputed rates and sensitivity analyses, exercised diagnostics and rendered
an offline HTML report. This exposed and fixed a presentation issue where tiny
values made other numbers in a report column excessively long. Numeric result
tables are unchanged; all ten exported CSVs match before and after the fix.
The corrected archive passes local --as-cran checks with 0 errors, warnings or
notes, including both manuals and 394 assertions (two intended CRAN skips).
Its maximum example time is 0.65 seconds; installed size is
3,173,589 bytes. Earlier external results above predate this display
change. The new win-builder result remains pending and must be inspected before
submission. Current source hash and scoped receipts are in RELEASE_READY.md.

## Additional validation

All 394 CRAN-mode assertions pass, with two intended CRAN skips. Full developer
tests include recovery and visual snapshots; line coverage is 94.9358%.
Examples, tests and precomputed vignettes use offline data. Test resources are
capped at two threads. Before the authorship update, the maximum example time was 2.21 seconds locally and
0.36 seconds on win-builder. Installed size was 3,039,622 bytes; extdata is
810,818 bytes. Lint, spelling and all 16 checked package URLs are clean.

Spatial recovery, 180 missingness simulations, independent national count and
ratio reproduction, and the twelve-month benchmark are complete, with evidence
committed under inst/validation/. The offline report and four vignettes are
rendered and checked. The published fifteen-line quick start executes offline.
The public pkgdown site is deployed at https://blackthrive.github.io/searchlight/;
all 51 HTML pages return HTTP 200.
