# searchlight

An original R package for audited analysis of police stop and search records in
England and Wales, published by Black Thrive Global.

Development follows the acceptance gates in [AGENTS.md](AGENTS.md). See
[the release checklist](RELEASE_CHECKLIST.md) for verified progress. A package
version of 0.1.0 denotes the intended release; it does not assert release readiness.

Records are events, not unique people. Missing force submissions are not zeros.
Self-defined ethnicity remains separate from officer-defined ethnicity. Sampling
uncertainty and assumptions about missing data and exposure are reported separately.

MIT licensed code. Bundled public data retain their Open Government Licence v3.0
attribution in `inst/extdata/README.md`. No code from policedatR, ExtractSS, or
ukpolice is used or imported.

## Offline quick start

```r
library(searchlight)
records <- sl_sample()
contract <- sl_contract(records)
print(contract)
summary(contract)
contract$snapshots
contract$versions
contract$timestamps
table(records$ethnicity_5)
table(records$ethnicity_officer)
table(records$force_id, records$month)
head(records[, c("date", "ethnicity_5", "any_action", "arrest")])
subset <- dplyr::filter(records, month == "2026-07")
sl_contract(subset)$scope
stopifnot(inherits(subset, "sl_records"))
```

The default May-July 2026 sample contains 4,657 West Yorkshire records.
Dyfed-Powys is retained in the requested sample grid; its three missing CSVs are
reported as missing submissions. CSV contents are unmodified and gzip-compressed.
