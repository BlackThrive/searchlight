# Bound disparity under allocations of Unknown ethnicity

Extreme allocations send every Unknown event to one of the two groups.
Proportional allocation uses all known groups, not only the comparison
pair. force_object_mar uses known-group shares within force and object,
pooled over areas and months; it refuses strata with no known ethnicity.
These are assumptions, not confidence intervals. Force/object allocation
also assumes pooled known composition applies to each recipient
area/month; MAR alone does not establish that transportability. The
tipping share solves the equation where the ratio equals one, with all
remaining Unknown sent to the reference. A tipping value outside zero to
one means no feasible tipping allocation.

## Usage

``` r
sl_missing_ethnicity_bounds(
  counts,
  population,
  reference = "White",
  comparison = "Black",
  scenarios = c("all_to_reference", "all_to_comparison", "proportional",
    "force_object_mar")
)
```

## Arguments

- counts:

  Contract-bearing event counts.

- population:

  Marginal ethnic-group exposure table.

- reference, comparison:

  Groups to compare.

- scenarios:

  Allocation assumptions to report.

## Value

An sl_sensitivity tibble with scenario ratios, extreme bounds, tipping
allocation and separately labelled baseline sampling intervals.

## See also

[`sl_rates()`](https://blackthrive.github.io/searchlight/reference/sl_rates.md),
[`sl_denominator_scenarios()`](https://blackthrive.github.io/searchlight/reference/sl_denominator_scenarios.md)

Other sensitivity:
[`sl_denominator_scenarios()`](https://blackthrive.github.io/searchlight/reference/sl_denominator_scenarios.md),
[`sl_ranking_stability()`](https://blackthrive.github.io/searchlight/reference/sl_ranking_stability.md),
[`sl_standardise()`](https://blackthrive.github.io/searchlight/reference/sl_standardise.md)

## Examples

``` r
c <- readRDS(system.file("extdata", "example-counts.rds",
  package = "searchlight"
))
p <- readRDS(system.file("extdata", "sample-population.rds",
  package = "searchlight"
))$msoa21
head(sl_missing_ethnicity_bounds(c, p))
#> sampling uncertainty: E02002237 [0, 7.45]; E02002454 [0.00502, 1.16]; E02006875
#> [0.0574, 0.833]; ... see table for remaining areas
#> baseline exact Poisson intervals conditional on recorded ethnicity
#> assumption range: E02002237 [0, 85.5]; E02002454 [0.141, 6.44]
#> lower_bound and upper_bound allocate all Unknown between the two groups
#> # A tibble: 6 × 15
#>   force_id       geography_code scenario       ratio unknown allocated_reference
#>   <chr>          <chr>          <chr>          <dbl>   <int>               <dbl>
#> 1 west-yorkshire E02002237      all_to_refer…  0          47                47  
#> 2 west-yorkshire E02002237      all_to_compa… 85.5        47                 0  
#> 3 west-yorkshire E02002237      proportional   0          47                35.2
#> 4 west-yorkshire E02002237      force_object…  0.486      47                42.2
#> 5 west-yorkshire E02002454      all_to_refer…  0.141      31                31  
#> 6 west-yorkshire E02002454      all_to_compa…  6.44       31                 0  
#> # ℹ 9 more variables: allocated_comparison <dbl>, lower_bound <dbl>,
#> #   upper_bound <dbl>, tipping_allocation <dbl>, available <lgl>,
#> #   tipping_feasible <lgl>, observed_ratio <dbl>, conf_low <dbl>,
#> #   conf_high <dbl>
```
