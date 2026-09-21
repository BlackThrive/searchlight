Milestone: M0 complete (2026-09-16).
Completed: package skeleton, source tables, tests, lint and local as-CRAN check (0 errors/warnings/notes; remote incoming and clock checks disabled).
Next: M1 archive ingestion and immutable revision contracts.

Milestone: M1 complete (2026-09-16).
Completed: verified archive acquisition, immutable revisions, parsing, contracts, real sample, 92.3% line coverage and a clean local as-CRAN check; all examples under five seconds.
Next: M2 geography, population, coverage audit and quality diagnostics.

Milestone: M2 complete (2026-09-16).
Completed: verified ONS and NOMIS acquisition, full sample audit, benchmark, offline tests, 94.5% coverage, clean lint and isolated local as-CRAN check with all examples under five seconds.
Next: M3 baseline event rates and separate sampling/assumption sensitivity.

Milestone: M3 complete (2026-09-16).
Completed: event rates, exact ratios, missingness/denominator/standardisation/rank sensitivity, 90 targeted assertions, offline vignette, 94.5% coverage and clean local as-CRAN check.
Next: M4 count and spatial inference, simulation recovery, separate outcome diagnostics and timestamp-gated darkness design.

Milestone: M4 complete (2026-09-16).
Completed: count/spatial/outcome/darkness inference, 18-fit simulation pilot, corrected sample classification, rendered vignettes, 94.7% coverage, clean lint and local as-CRAN check; slowest example 1.68 seconds.
Next: M5 offline report, remaining validation studies, national benchmark and release evidence; external checks depend on a reachable repository.

Milestone: M5 implemented and verified locally; external release gates pending (2026-09-16).
Completed: offline report, four vignettes, local pkgdown, all four validation studies, clean manual-inclusive local as-CRAN check, 94.9358% coverage, style/lint/spelling and example/size gates.
Next: make the configured GitHub repository accessible, verify the full CI/R-hub/win-builder results, resolve URL checks and deploy pkgdown; the maintainer decides CRAN submission.

Milestone: M5 GitHub publication (2026-09-21).
Completed: confirmed BlackThrive as owner, created its public searchlight repository, corrected metadata and README links, preserved win-builder evidence, and passed the local manual-inclusive as-CRAN check with no errors, warnings or notes.
Next: publish source, verify hosted checks and documentation, then rebuild the source artifact; retain human authorship and leave CRAN submission to the maintainer.

Milestone: M5 hosted validation and release evidence (2026-09-21).
Completed: published BlackThrive/searchlight and its 51-page site; seven matrix jobs pass; spelling/lint/URLs and exact source archive check pass; fresh win-builder upload acknowledged; no AI co-author credits.
Next: verify Linux R-devel and the macOS system-library fix in the queued matrix and R-hub jobs, review pull request 1, and inspect the new win-builder email before declaring release readiness; CRAN submission remains with the maintainer.

Milestone: M5 corrected win-builder result verified (2026-09-21).
Completed: win-builder 0 errors, 0 warnings, only New submission NOTE; all 392 assertions and both manuals pass; logs, binary and exact archive preserved; eight CI jobs and R-hub Linux/Windows pass.
Next: verify the remaining macOS R-devel CI/R-hub results and release review before declaring readiness; the maintainer submits to CRAN.

Milestone: M5 macOS build correction and full-matrix verification (2026-09-21).
Completed: matched s2's macOS Abseil headers/libraries; all nine manual-inclusive CI jobs and Quality pass; clean CI and R-hub Linux/Windows logs preserved; source archive and human authorship technically reviewed.
Next: finish the active Intel macOS R-hub validation and finalize RELEASE_READY.md; the maintainer submits the preserved archive to CRAN.
