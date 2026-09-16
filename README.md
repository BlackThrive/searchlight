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
print(sl_contract(records))
coverage <- sl_coverage(records)
plot(coverage)
sl_timestamp_quality(records)
data_file <- function(x) system.file("extdata", x, package = "searchlight")
counts <- readRDS(data_file("example-counts.rds"))
population <- readRDS(data_file("sample-population.rds"))$msoa21
rates <- readRDS(data_file("example-rates.rds"))
ratios <- sl_rate_ratio(rates)
ratios[c("geography_code", "ratio", "conf_low", "conf_high")]
sl_missing_ethnicity_bounds(counts, population)
sl_ranking_stability(ratios, n = 200)
vignette("estimating-disparity")
```

The default May-July 2026 sample contains 4,657 West Yorkshire records.
Dyfed-Powys is retained in the requested sample grid; its three missing CSVs are
reported as missing submissions. CSV contents are unmodified and gzip-compressed.

Matching LSOA/MSOA boundaries and Census populations are bundled for both forces.
Geographical diagnostics use the original ONS BGC boundaries; compact example
polygons are simplified. Almost half the assigned sample points lie within 50 m
of an LSOA boundary. These are anonymised snap points, so geographical error can
be systematic. The coverage audit does not turn missing submissions into zeros.

The quick-start rate tables contain four MSOAs selected to keep the examples
small. Their ratio is an event-rate ratio with submitted population-time exposure.
Poisson sampling intervals and missing-ethnicity allocation ranges answer different
questions; neither corrects an unsuitable denominator or establishes discrimination.
