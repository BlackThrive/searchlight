# Release evidence

- [x] M0: skeleton and clean local R CMD check (see `inst/validation/M0-check.log`)
- [x] M1: archive ingestion, revision selection and contract fixtures
- [x] M2: verified geography, population, coverage and quality
- [x] M3: known-answer rates and sensitivity, rendered vignette
- [x] M4: inference, spatial recovery evidence, outcome and darkness tests
- [x] Offline sample HTML report rendered and inspected on desktop and mobile
- [x] Missingness study: 180 lattices; all 4,500 realised ratios inside bounds
- [x] Independent national CSV/Census reference for 43 territorial forces
- [x] Actual package ingestion and ratios match that independent reference
- [x] National twelve-month timing comparison complete and reported in README
- [x] Four final precomputed vignettes rendered and inspected
- [x] Published fifteen-line quick start executes successfully offline
- [x] Final coverage at least 85%: 94.9358%, including full recovery and snapshots
- [x] Package lint clean after report and missing-submission fixes
- [x] Final local M5 as-CRAN check: 0 errors/warnings/notes, PDF/HTML manuals included
- [x] Examples below five seconds (maximum 2.25); installed 2.94 MB, extdata 0.81 MB
- [x] Final spelling check clean
- [ ] URL check clean
- [x] Local pkgdown site built and inspected; 51 pages have valid local links
- [x] Win-builder R-devel upload acknowledged over HTTPS; receipt and hash saved
- [ ] Full R/OS CI matrix, rhub and win-builder verified
- [ ] pkgdown deployed and milestone pull requests reviewed

The specified GitHub repository remains unavailable. Remote CI, R-hub,
deployment and milestone PR publication are pending. R-hub was attempted and
returned Not Found. The required placeholder
URLs are retained. URL checking also encountered a 403 response from the RAND
paper server; its source was verified separately and the automatic failure is
not treated as a pass.

Win-builder's check result is pending delivery to the DESCRIPTION maintainer
email. Upload confirmation is not a successful check result.

No release-ready assertion is made until every required check has evidence.
