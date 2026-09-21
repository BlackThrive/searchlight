# Write an offline report of audited records and analysis results

Renders the installed Markdown/Rmd template to a self-contained HTML
file. No Pandoc, network, model fitting or external web assets are
required. Supplied estimates must retain the same source snapshots and
ethnicity classification as records. Their analysis scope and
diagnostics are shown. Coverage describes source files; filtering does
not redefine coverage. Sampling intervals and assumption ranges have
separate labelled sections.

## Usage

``` r
sl_report(
  records,
  file,
  estimates = list(),
  title = "Stop and search: evidence and assumptions",
  assumptions = character(),
  limitations = character(),
  max_rows = 500,
  overwrite = FALSE
)
```

## Arguments

- records:

  Contract-bearing search records.

- file:

  Explicit HTML output path. Its parent directory must exist.

- estimates:

  Uniquely named list of contract-bearing result tables.

- title:

  Report title, treated as text.

- assumptions, limitations:

  Additional statements, treated as text.

- max_rows:

  Maximum displayed rows per table; truncation is labelled.

- overwrite:

  Whether to replace an existing output file.

## Value

Invisibly, a one-row tibble with the output path and record count,
carrying the ingestion contract. Writes only the requested output file.

## See also

[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md),
[`sl_rate_ratio()`](https://blackthrive.github.io/searchlight/reference/sl_rate_ratio.md),
[`sl_missing_ethnicity_bounds()`](https://blackthrive.github.io/searchlight/reference/sl_missing_ethnicity_bounds.md)

## Examples

``` r
rates <- readRDS(system.file("extdata", "example-rates.rds",
  package = "searchlight"
))
path <- tempfile(fileext = ".html")
sl_report(sl_sample(), path, estimates = list(ratios = sl_rate_ratio(rates)))
#> Report written to /tmp/RtmpmjGARD/file1e48429c16a7.html.
file.exists(path)
#> [1] TRUE
```
