# Calculate rates using observed population-time exposure

The primary rate is annualised events per 1,000 resident person-years: n
/ (population \* submitted_months / 12) \* per. The separate period_rate
is n / population \* per for that cell. Neither is a probability of a
person being searched. NA submission counts are excluded from time
exposure. Partial submissions remain flagged and describe reported
events only.

## Usage

``` r
sl_rates(counts, population, per = 1000)
```

## Arguments

- counts:

  Output from sl_counts.

- population:

  A compatible sl_exposure table.

- per:

  Rate scaling, default 1000.

## Value

An sl_rates tibble with population, exposure, rate and period_rate.

## See also

[`sl_counts()`](https://blackthrive.github.io/searchlight/reference/sl_counts.md),
[`sl_rate_ratio()`](https://blackthrive.github.io/searchlight/reference/sl_rate_ratio.md),
[`sl_exposure()`](https://blackthrive.github.io/searchlight/reference/sl_exposure.md)

Other rates:
[`sl_counts()`](https://blackthrive.github.io/searchlight/reference/sl_counts.md),
[`sl_rate_ratio()`](https://blackthrive.github.io/searchlight/reference/sl_rate_ratio.md)

## Examples

``` r
c <- readRDS(system.file("extdata", "example-counts.rds",
  package = "searchlight"
))
p <- readRDS(system.file("extdata", "sample-population.rds",
  package = "searchlight"
))$msoa21
head(sl_rates(c, p))
#> # A tibble: 6 × 14
#>   force_id     month status msoa21 ethnicity_5 object_group     n geography_code
#>   <chr>        <chr> <chr>  <chr>  <chr>       <chr>        <int> <chr>         
#> 1 west-yorksh… 2026… submi… E0200… Asian       Drugs            0 E02002237     
#> 2 west-yorksh… 2026… submi… E0200… Asian       Drugs            0 E02006948     
#> 3 west-yorksh… 2026… submi… E0200… Asian       Drugs            1 E02002454     
#> 4 west-yorksh… 2026… submi… E0200… Asian       Drugs            3 E02006875     
#> 5 west-yorksh… 2026… submi… E0200… Asian       Drugs            0 E02002237     
#> 6 west-yorksh… 2026… submi… E0200… Asian       Drugs            4 E02006948     
#> # ℹ 6 more variables: ethnicity <chr>, months_submitted <int>,
#> #   population <dbl>, exposure <dbl>, period_rate <dbl>, rate <dbl>
```
