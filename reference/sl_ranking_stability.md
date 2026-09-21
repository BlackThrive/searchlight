# Assess area rank uncertainty under count models or posterior draws

Bootstrap draws event counts from the fitted Poisson or
negative-binomial model, then ranks event-rate ratios (largest is rank
1). Quasi-Poisson does not define a count distribution and is refused.
Positive totals in both groups are required for plug-in bootstrap;
sparse zero-count areas need a suitable posterior model. Ties receive
random ranks under the saved seed. Optional scenario rows are analysed
separately, never pooled into a sampling distribution. Pairwise
stability means ordering probability above 0.95.

## Usage

``` r
sl_ranking_stability(
  rate_ratios,
  method = c("bootstrap", "posterior"),
  n = 1000,
  seed = 1
)
```

## Arguments

- rate_ratios:

  An sl_rate_ratio table, or a contract-bearing table with
  geography_code and a posterior_draws matrix attribute (draws by area).

- method:

  Parametric bootstrap or posterior ranks.

- n:

  Number of draws; default 1000.

- seed:

  Reproducible seed, restored on exit.

## Value

An sl_sensitivity tibble of median/95% rank intervals, with attributes
rank_probabilities (matrix) and pairwise (ordering probabilities).

## See also

[`sl_rate_ratio()`](https://blackthrive.github.io/searchlight/reference/sl_rate_ratio.md),
[`sl_denominator_scenarios()`](https://blackthrive.github.io/searchlight/reference/sl_denominator_scenarios.md)

Other sensitivity:
[`sl_denominator_scenarios()`](https://blackthrive.github.io/searchlight/reference/sl_denominator_scenarios.md),
[`sl_missing_ethnicity_bounds()`](https://blackthrive.github.io/searchlight/reference/sl_missing_ethnicity_bounds.md),
[`sl_standardise()`](https://blackthrive.github.io/searchlight/reference/sl_standardise.md)

## Examples

``` r
# Posterior draws can also be supplied by an independently fitted model.
x <- tibble::tibble(geography_code = c("a", "b"))
attr(x, "contract") <- sl_contract(sl_sample())
attr(x, "posterior_draws") <- cbind(a = c(1, 2, 3), b = c(3, 2, 1))
sl_ranking_stability(x, "posterior", n = 3)
#> sampling uncertainty: not evaluated
#> rank_low/rank_high describe conditional sampling or posterior ranks
#> assumption range: not evaluated
#> not evaluated for this single scenario
#> # A tibble: 2 × 6
#>   geography_code median_rank rank_low rank_high effective_draws method   
#>   <chr>                <int>    <dbl>     <dbl>           <int> <chr>    
#> 1 a                        1        1         2               3 posterior
#> 2 b                        2        1         2               3 posterior
```
