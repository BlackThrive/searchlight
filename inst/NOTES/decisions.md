# Decisions

## 2026-09-16: M0

* Created `searchlight/` as an independent Git repository within the supplied
  workspace; existing applications were not read or used as source material.
  Saved the supplied specification verbatim as AGENTS.md and read it in full.
* Used `usethis::create_package()` and MIT licence scaffolding. No existing package
  was present, so the initial session check starts after the skeleton is written.
* Maintainer email comes from the user's configured Git identity. Name and roles
  follow the specification; no ORCID is invented.
* Add runtime dependencies when first used to avoid unused-import check notes on
  earlier milestones. Defer VignetteBuilder until there are actual vignettes.
* R 4.5.2 is available. The inherited C.UTF-8 locale is unsupported by this
  Windows R build; check commands use en_US.UTF-8 process-local environment.
* The specified GitHub URL does not resolve for the authenticated account.
  Keep it as the required placeholder, record URL-check failure honestly, and
  prepare local milestone PR descriptions. Do not create a different remote
  or claim that CI, hosted documentation, rhub, or win-builder have run.
* Official archive checksums are MD5. Verify MD5 before creating a SHA-256 manifest;
  the latter detects later corruption, and is not a publisher-authenticated hash.
* PACE 2023 includes Roma. Pin the code mapping version; historical numeric or
  abbreviated codes must not be silently interpreted using an incompatible scheme.
* The first as-CRAN check reported only an inability to verify the current time
  over the network. Set `_R_CHECK_SYSTEM_CLOCK_=FALSE` for offline local/CI checks;
  this avoids an unrelated external clock request and is disclosed in results.

## 2026-09-16: M1

* The latest three complete available months are May-July 2026. The requested
  Dyfed-Powys files are absent in the latest bulk snapshot. Retain this force and
  missingness in the contract, per the specified default; do not replace it or
  invent records. Synthetic two-force archives independently test ingestion.
* Bundled sample CSVs are byte-preserving gzip copies. Manifests retain both the
  original CSV SHA-256 and the compressed-file SHA-256, plus full archive SHA-256.
* Retain unknown outcomes as NA for each binary measure. The presence of an NFA
  outcome does not override an independently reported linked-to-object flag.
* Source coverage remains provenance after filtering; a separate contract scope
  describes current rows. An analysis filter must not rewrite source submission
  status. Retain both the requested force-month grid and selected versions.
* Skip the malformed checksum on 2019-06.zip when choosing downloads; its
  published multipart-style value is retained in the index for audit.
