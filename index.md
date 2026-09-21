# searchlight

An original R package for audited analysis of police stop and search
records in England and Wales, published by Black Thrive Global.

Development follows the acceptance gates in the repository’s
`AGENTS.md`. See the repository’s `RELEASE_CHECKLIST.md` for verified
progress. A package version of 0.1.0 denotes the intended release; it
does not assert release readiness.

Records are events, not unique people. Missing force submissions are not
zeros. Self-defined ethnicity remains separate from officer-defined
ethnicity. Sampling uncertainty and assumptions about missing data and
exposure are reported separately.

MIT licensed code. Bundled public data retain their Open Government
Licence v3.0 attribution in `inst/extdata/README.md`. No code from
policedatR, ExtractSS, or ukpolice is used or imported.

This is a development package. To install a locally built source
archive, run `R CMD INSTALL searchlight_0.1.0.tar.gz` after installing
the dependencies listed in `DESCRIPTION`. Network access is needed for
explicit data acquisition; the bundled examples, vignettes and report
run offline.

## Offline quick start

``` r

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
sl_ranking_stability(ratios[ratios$n_comparison > 0, ], n = 200)
sl_report(records, tempfile(fileext = ".html"), list(ratios = ratios))
```

The default May-July 2026 sample contains 4,657 West Yorkshire records.
Dyfed-Powys is retained in the requested sample grid; its three missing
CSVs are reported as missing submissions. CSV contents are unmodified
and gzip-compressed.

Matching LSOA/MSOA boundaries and Census populations are bundled for
both forces. Geographical diagnostics use the original ONS BGC
boundaries; compact example polygons are simplified. Almost half the
assigned sample points lie within 50 m of an LSOA boundary. These are
anonymised snap points, so geographical error can be systematic. The
coverage audit does not turn missing submissions into zeros.

The quick-start rate tables contain four MSOAs selected to keep the
examples small. Their ratio is an event-rate ratio with submitted
population-time exposure. Poisson sampling intervals and
missing-ethnicity allocation ranges answer different questions; neither
corrects an unsuitable denominator or establishes discrimination. The
bootstrap example ranks the three MSOAs with positive Black counts. The
zero-count area remains in the rate and sensitivity tables; ranking it
requires an appropriate posterior model, as demonstrated in the spatial
vignette.

Four offline vignettes cover the archive audit, explicit assumptions,
replicated spatial smoothing evidence, and outcome/darkness diagnostics.
Start with
[`vignette("archive-to-audit")`](https://blackthrive.github.io/searchlight/articles/archive-to-audit.md).
[`sl_report()`](https://blackthrive.github.io/searchlight/reference/sl_report.md)
creates a self-contained HTML report with coverage, result-specific
scope, diagnostics, sources and limitations.

## Validation evidence

The missing-ethnicity study ran 180 independent 25-area simulations: 20
per combination of mechanism and baseline missingness. All 4,500
complete realised event ratios lay within the extreme-allocation bounds.
Under MCAR, the mean replicate median width increased from 1.05 at 10%
missingness to 3.77 at 30% and 12.33 at 60%. These are assumption ranges
on the ratio scale, not confidence intervals for the generating process.
The vignette reports MAR and MNAR results and the saved tables include
Monte Carlo uncertainty.

The spatial pilot retains all 18 fits, including one sparse-population
fit that failed the predeclared convergence screen. Its area-level
evidence shows both improvements and local losses from smoothing.
Neither the pilot nor an average error improvement establishes that
every local estimate is better.

Scripts and measured outputs are in `inst/scripts/` and
`inst/validation/`. The independent national reference covers August
2025-July 2026: 43 territorial forces, 430 submitted files and 476,738
events. Only 28 forces supplied all twelve months; missing and partial
years remain explicit. British Transport Police is outside this archive
force-list scope.

## Measured national benchmark

The local 12-month build processed 476,738 events against 7,264 MSOAs.
Both methods produced the same event assignments and aggregate counts.
Elapsed and CPU times are measured seconds; CPU combines user and system
time.

| Run | Method                 | Total elapsed | Spatial elapsed | Total CPU |
|-----|------------------------|--------------:|----------------:|----------:|
| 1   | One national batch     |        1042.7 |           575.7 |     368.0 |
| 1   | Twelve monthly batches |         544.1 |           433.1 |     523.4 |

The comparison includes ZIP/CSV verification, parsing, coverage audit,
local spatial assignment and aggregation. Initial downloads, library
loading and writing validation artifacts are excluded. The ZIP,
extracted CSVs and ONS boundaries were already cached. OS caching and
concurrent workstation load were uncontrolled; these timings are not a
hardware-independent guarantee. The monthly comparison resumed in a new
R process against the saved national result. The alternative repeats
boundary preparation and assignment each month. Stage timings,
environment and scope are retained in
`inst/validation/benchmark-national.csv` and its manifest.
