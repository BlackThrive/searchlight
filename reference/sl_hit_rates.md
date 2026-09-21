# Describe three separate outcomes conditional on being searched

Computes each requested outcome separately with Wilson binomial
intervals. Unknown ethnicity remains in descriptive tables and missing
outcomes are not failures. Logistic comparisons use known ethnicity,
force and object fixed effects; constant controls are explicitly
omitted. These are associations among searches. Differing hit rates
alone do not establish discrimination; selection, differing risk
distributions and infra-marginality matter.

## Usage

``` r
sl_hit_rates(
  records,
  by = c("pfa", "object_group"),
  outcome = c("any_action", "arrest", "outcome_linked_to_object"),
  reference = "White",
  comparison = "Black",
  conf_level = 0.95
)
```

## Arguments

- records:

  Search records with the three derived binary outcome measures.

- by:

  Descriptive grouping columns; ethnicity_5 is always retained.

- outcome:

  Separate outcomes to calculate (all three by default).

- reference, comparison:

  Known self-defined ethnicity groups.

- conf_level:

  Wilson and logistic Wald confidence level.

## Value

An sl_hit_rates tibble. Models, coefficients and exclusions describe
separate logistic models. The ingestion contract is retained.

## See also

[`sl_read_records()`](https://blackthrive.github.io/searchlight/reference/sl_read_records.md),
[`sl_veil_of_darkness()`](https://blackthrive.github.io/searchlight/reference/sl_veil_of_darkness.md)

Other inference:
[`sl_count_model()`](https://blackthrive.github.io/searchlight/reference/sl_count_model.md),
[`sl_simulate()`](https://blackthrive.github.io/searchlight/reference/sl_simulate.md),
[`sl_spatial_disparity()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_disparity.md),
[`sl_spatial_map()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_map.md),
[`sl_veil_of_darkness()`](https://blackthrive.github.io/searchlight/reference/sl_veil_of_darkness.md)

## Examples

``` r
hits <- sl_hit_rates(sl_sample())
head(hits)
#> # A tibble: 6 × 11
#>   pfa       object_group ethnicity_5 searches observed successes missing_outcome
#>   <chr>     <chr>        <chr>          <int>    <int>     <dbl>           <int>
#> 1 E23000010 Drugs        Asian             96       95        23               1
#> 2 E23000010 Drugs        Black             40       40        17               0
#> 3 E23000010 Drugs        Other             34       34         9               0
#> 4 E23000010 Drugs        Unknown         1670     1663       669               7
#> 5 E23000010 Drugs        White           1297     1295       493               2
#> 6 E23000010 Other        Asian              9        9         1               0
#> # ℹ 4 more variables: hit_rate <dbl>, conf_low <dbl>, conf_high <dbl>,
#> #   outcome <chr>
attr(hits, "coefficients")
#> # A tibble: 3 × 10
#>   term   odds_ratio conf_low conf_high log_std_error     n status model_warnings
#>   <chr>       <dbl>    <dbl>     <dbl>         <dbl> <int> <chr>  <chr>         
#> 1 .comp…      1.08     0.630      1.86         0.276  2196 estim… ""            
#> 2 .comp…      0.991    0.506      1.94         0.343  2196 estim… ""            
#> 3 .comp…      0.585    0.271      1.26         0.392  2199 estim… ""            
#> # ℹ 2 more variables: outcome <chr>, omitted_constant_controls <chr>
```
