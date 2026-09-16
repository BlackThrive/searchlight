# Validation evidence

These are measured outputs and reproducible references, not release certification.
M0-M4 checks were run locally on Windows, with their recorded offline incoming
and clock-check exceptions. External CI and hosted checks require separate evidence.
M5 additionally checked PDF and HTML manuals: zero errors, warnings and notes,
392 check-mode assertions, 94.9358% full-test line coverage, and all example and
size limits satisfied. The R-devel HTTPS upload was acknowledged; its check
result is pending. R-hub returned Not Found for the specified GitHub repository.

The national snapshot covers August 2025-July 2026 for the 43 territorial police
forces in England and Wales. British Transport Police is absent from the source
force list; Northern Ireland is excluded. There are 430 submitted files and
476,738 recorded events. Only 28 forces have all twelve submissions. Partial or
missing years must not be presented as fully observed annual totals.

`national-raw-*` and `national-force-month-labels.csv` come from an independent
Python standard-library scan of unmodified archive CSVs. `reproduction-expected`
uses those source labels and independently acquired NOMIS Census 2021 population
cells, aggregated via ONS LAD22-PFA22 lookup. The accompanying Python script
does not import searchlight or its ethnicity mapping. R verification subsequently
compares both monthly counts from actual parsed records and force-level ratios.

Population geography is the documented Census/2022 force-area vintage. Applying
it to 2025-2026 events assumes an appropriate resident exposure; this reference
is an arithmetic reproduction, not validation of the denominator assumption.

Source: Office for National Statistics licensed under the Open Government Licence
v3.0. Contains public sector information licensed under the Open Government Licence
v3.0. Archive event data: data.police.uk; Census counts: ONS via NOMIS. Source URLs
and input hashes are retained in the corresponding manifests.
