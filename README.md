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
coverage <- sl_coverage(records)
plot(coverage)
sl_timestamp_quality(records)
head(sl_location_quality(records))
sl_benchmark(records)
population <- readRDS(system.file("extdata", "sample-population.rds",
                                 package = "searchlight"))
head(population$msoa21)
sl_contract(records)$assignment_quality
table(records$ethnicity_5)
```

The default May-July 2026 sample contains 4,657 West Yorkshire records.
Dyfed-Powys is retained in the requested sample grid; its three missing CSVs are
reported as missing submissions. CSV contents are unmodified and gzip-compressed.

Matching LSOA/MSOA boundaries and Census populations are bundled for both forces.
Geographical diagnostics use the original ONS BGC boundaries; compact example
polygons are simplified. Almost half the assigned sample points lie within 50 m
of an LSOA boundary. These are anonymised snap points, so geographical error can
be systematic. The coverage audit does not turn missing submissions into zeros.
