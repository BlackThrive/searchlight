# Source register

## Verified 2026-09-16

* https://data.police.uk/data/archive/ (HTML retrieved): archives are complete
  rolling snapshots, not one-month-only datasets. The latest is `2026-07.zip`,
  covering August 2023 through July 2026, about 1.6 GB. Published checksums are
  MD5, not SHA-256. Verify published MD5 on acquisition and record a locally
  computed SHA-256 for subsequent integrity checks. Select archives by advertised
  coverage ranges, not simply one ZIP per requested month.
* https://data.police.uk/about/: stop and search begins December 2014, initially
  covering a subset of forces; records are OGL v3. Coordinates are anonymised
  snap points, so boundary errors can be systematic.
* https://data.police.uk/docs/method/stops-street/: field semantics verified
  without using the record acquisition API. Some forces provide dates without
  times, appearing at midnight; absent outcome values are unknown, not NFA.
* https://data.police.uk/api/forces: retrieved verbatim to `extdata/forces.json`.
* https://www.ons.gov.uk/census/census2021dictionary/variablesbytopic/ethnicgroupnationalidentitylanguageandreligionvariablescensus2021/ethnicgroup/classifications:
  verified the 19 substantive Census 2021 groups and 5 broad groups. Census -8
  means does not apply; it is not a police missing-ethnicity denominator.
* https://www.gov.uk/government/publications/pace-code-a-december-2023/pace-code-a-2023-accessible#annex-b-self-defined-ethnic-classification-categories:
  verified current PACE codes including W4 (Roma), O1 (Arab), A4 (Chinese).

CSV layout, ONS boundary layers, NOMIS tables and Home Office benchmark values
will be added only after direct verification at their milestone. No guessed
endpoint or unverified benchmark is treated as a source.
