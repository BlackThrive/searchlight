# Bundled data

Contains public sector information licensed under the
[Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
Code is separately MIT licensed. Retrieved / verified on 2026-09-16.

* `forces.json`: unmodified response from https://data.police.uk/api/forces.
* `ethnicity.csv`: crosswalk prepared independently from ONS Census 2021 ethnic
  group codes and Annex B of Home Office PACE Code A 2023. Short labels are used.
  The additional Unknown category is a searchlight missingness category, not
  the Census -8 (does not apply) category. Police codes use PACE 2023, not legacy
  16+1 coding: W4 is Roma, O1 is Arab, and A4 is Chinese.
* `officer-ethnicity.csv`: separately retained textual officer scheme. It is not
  a crosswalk from perceived ethnicity to self-defined Census ethnicity.

Full source links, semantics and verification dates are in `NOTES/data_sources.md`.

The sample consists of original gzip-compressed CSVs, hashes, and a precomputed
`sample-records.rds` for fast offline examples. The May-July 2026 request includes
West Yorkshire and Dyfed-Powys. Only West Yorkshire submitted files in this
window; the contract explicitly retains all three missing Dyfed-Powys months.
## Geography and population sample (M2)

Contains ONS data licensed under the Open Government Licence v3. Contains OS
data Crown copyright and database right 2026. Census data: Crown copyright,
ONS Census 2021 via NOMIS. Home Office benchmark data: Crown copyright, OGL v3.
All retrieved 2026-09-16; source IDs, fields and vintage details are recorded in
`inst/NOTES/data_sources.md`.

* `sample-boundaries.rds`: 1,710 LSOA21 and 370 MSOA21 polygons across the whole
  nine LADs of West Yorkshire and Dyfed-Powys, mapshaper keep=0.2, keep_shapes.
  These compact polygons are for examples. Sample record assignments and their
  distances were calculated on the original ONS BGC 20 m polygons.
* `sample-population.rds`: matching TS021 counts (five groups plus Unknown NA).
* `sample-crosstab.rds`: RM032 counts at MSOA, five groups by harmonised age and
  sex; under 25, 25-34, 35+, Female/Male. Unknown exposure is NA.
* `standard-population.rds`: RM032 England/Wales reference population.
* `sample-lookups.rds`: official whole-unit membership; no partial-area exposure.
* `ppap-totals.csv`: all 44 SS_20 force totals, year ending March 2025.
* `changelog-2026-09-16.html.gz`: full original retrieved changelog.
  `changelog.csv` is a conservative unresolved-issue extract for this sample.

Builders: `data-raw/sample-audit.R`, `data-raw/audit-sources.py`.
No acquisition happens when loading these files or running examples.

## Derived rate examples

`example-counts.rds`, `example-rates.rds` and
`example-demographic-counts.rds` retain four West Yorkshire MSOAs with the most
sample events, all three months, unknown ethnicity and the full ingestion
contract. They are built by `data-raw/sample-rates.R` from the attributed real
sample above and are used to keep installed examples fast and network-free.

## Synthetic spatial example

`example-spatial.rds` is wholly synthetic, created by
`inst/scripts/simulation-study.R` from a 25-area lattice with known independent
disparity and total-intensity surfaces. It is not police or Census data. Its
contract states that origin. The compact file retains posterior summaries,
full-chain diagnostics, settings, truth and 1,000 evenly spaced joint draws;
the large backend fit is omitted. Simulation outputs are under `inst/validation`.
