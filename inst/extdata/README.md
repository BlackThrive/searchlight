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
