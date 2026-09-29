## First submission

This is the first CRAN submission of searchlight 0.1.0, for audited analysis
of police stop and search records. The package has no reverse dependencies.

## Current checks (2026-09-22)

* Win-builder, R-devel (2026-09-21 r90579 ucrt), Windows Server 2022 x64:
  0 errors, 0 warnings, 1 NOTE, solely "New submission". Examples, tests,
  vignettes and PDF/HTML manuals pass. Results:
  https://win-builder.r-project.org/J16WE4Ec1bDE/00check.log
* Linux, macOS and Windows, each with R release 4.6.1, R-devel and R 4.5.3:
  all nine --as-cran checks pass with 0 errors, warnings or notes, including
  PDF/HTML manuals. These checks cover the current report implementation:
  https://github.com/BlackThrive/searchlight/actions/runs/35688724233
* Exact source archive, Windows 11 x64, R 4.5.2: --as-cran passes with
  0 errors, warnings or notes, including both manuals. Local online incoming
  checks and the network clock probe are disabled; win-builder provides the
  current online incoming check.

All 407 CRAN-mode assertions pass, with two intended CRAN skips. The full
developer suite includes spatial recovery and visual snapshots; line coverage
is 95.0433%. Tests and examples run offline with resources capped at two threads.
The four precomputed vignettes are included. Lint and spelling are clean;
the 16 package URLs were verified on 2026-09-21 and are unchanged.

Installed size is 3,200,250 bytes; bundled extdata is 810,818 bytes. Win-builder's
longest example takes 0.35 seconds. An initial local check had a 16.28-second
elapsed-time outlier for sl_read_records (0.73 CPU seconds); isolated reruns
from the same installed archive took 0.53 and 0.17 seconds. The original
timing and reruns are retained in the validation evidence.

A fresh installation reparses all 4,657 bundled events, recomputes analyses,
exercises diagnostics and produces a self-contained HTML report. Sarah Hamed
and Souci Frissa are coauthors; Mustapha Wasseja is the sole maintainer.

Earlier R-hub checks passed on Linux, Windows and Intel macOS R-devel before
the report presentation changes, with --no-manual --as-cran. They are retained
as historical evidence, separately from the current checks above.
