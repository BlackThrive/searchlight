# Directly standardise age-sex stop-event rates

Uses common age-sex weights across ethnicity groups. Census sex is
compared with police-recorded gender only under an explicit measurement
assumption. Unknown age, gender and ethnicity are retained in exclusion
diagnostics. A positively weighted stratum with zero exposure makes the
standardised rate undefined; it is never silently dropped. Sampling
intervals combine exact Poisson stratum intervals with a Bonferroni
correction and fixed weights. They are conservative, including when
every observed stratum count is zero.

## Usage

``` r
sl_standardise(
  counts,
  crosstab,
  standard = c("england_wales", "study_population"),
  per = 1000
)
```

## Arguments

- counts:

  Counts grouped by age_band and sex.

- crosstab:

  Compatible Census or explicit ethnicity-age-sex exposure.

- standard:

  England/Wales Census 2021 or pooled study population weights.

- per:

  Rate scaling, default 1000 per person-year.

## Value

An sl_sensitivity tibble with crude and standardised rates, sampling
intervals, excluded-event counts, weights and the ingestion contract.

## See also

[`sl_population_crosstab()`](https://blackthrive.github.io/searchlight/reference/sl_population_crosstab.md),
[`sl_rates()`](https://blackthrive.github.io/searchlight/reference/sl_rates.md)

Other sensitivity:
[`sl_denominator_scenarios()`](https://blackthrive.github.io/searchlight/reference/sl_denominator_scenarios.md),
[`sl_missing_ethnicity_bounds()`](https://blackthrive.github.io/searchlight/reference/sl_missing_ethnicity_bounds.md),
[`sl_ranking_stability()`](https://blackthrive.github.io/searchlight/reference/sl_ranking_stability.md)

## Examples

``` r
p <- readRDS(system.file("extdata", "sample-crosstab.rds",
  package = "searchlight"
))
c <- readRDS(system.file("extdata", "example-demographic-counts.rds",
  package = "searchlight"
))
head(suppressWarnings(sl_standardise(c, p)))
#> sampling uncertainty: not evaluated
#> conf_low/conf_high combine simultaneous exact Poisson stratum intervals
#> assumption range: not evaluated
#> not evaluated; one declared standard population
#> # A tibble: 6 × 10
#>   force_id       geography_code ethnicity crude_rate standardised_rate conf_low
#>   <chr>          <chr>          <chr>          <dbl>             <dbl>    <dbl>
#> 1 west-yorkshire E02002237      Asian           4.69              3.40  0.0142 
#> 2 west-yorkshire E02002237      Black           0                 0     0      
#> 3 west-yorkshire E02002237      Mixed           0                 0     0      
#> 4 west-yorkshire E02002237      Other          83.3              67.6   1.66   
#> 5 west-yorkshire E02002237      White          12.7              13.0   2.70   
#> 6 west-yorkshire E02002454      Asian           1.58              1.19  0.00495
#> # ℹ 4 more variables: conf_high <dbl>, complete_strata <lgl>, standard <chr>,
#> #   excluded_events <dbl>
```
