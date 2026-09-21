# Count events while preserving submission strata

Force and month always remain in the result, even if omitted from by:
these identify independent reporting and time-exposure cells. Unknown
ethnicity remains a level. Missing submissions have NA counts; submitted
combinations without events have zero. Filtering records does not narrow
the source time grid: pass months and forces explicitly to select the
analysis period.

## Usage

``` r
sl_counts(
  records,
  by = c("pfa", "month", "ethnicity_5"),
  units = NULL,
  months = NULL,
  forces = NULL
)
```

## Arguments

- records:

  Contract-bearing records.

- by:

  Additional grouping columns, including exactly one ethnicity field.

- units:

  Optional force_id and geography mapping defining the full area
  universe, including areas without events. Otherwise uses contract
  units or observed areas. PFA defaults to the published force-code
  mapping.

- months, forces:

  Explicit analysis scope; defaults to contract coverage.

## Value

An sl_counts tibble with canonical geography_code, ethnicity, n,
force_id and month columns, original grouping fields, and coverage
status.

## See also

[`sl_rates()`](https://blackthrive.github.io/searchlight/reference/sl_rates.md),
[`sl_coverage()`](https://blackthrive.github.io/searchlight/reference/sl_coverage.md)

Other rates:
[`sl_rate_ratio()`](https://blackthrive.github.io/searchlight/reference/sl_rate_ratio.md),
[`sl_rates()`](https://blackthrive.github.io/searchlight/reference/sl_rates.md)

## Examples

``` r
counts <- sl_counts(sl_sample())
head(counts)
#> # A tibble: 6 × 9
#>   force_id       month   status pfa   ethnicity_5     n geography_code ethnicity
#>   <chr>          <chr>   <chr>  <chr> <chr>       <int> <chr>          <chr>    
#> 1 dyfed-powys    2026-05 missi… W150… Asian          NA W15000004      Asian    
#> 2 dyfed-powys    2026-06 missi… W150… Asian          NA W15000004      Asian    
#> 3 dyfed-powys    2026-07 missi… W150… Asian          NA W15000004      Asian    
#> 4 west-yorkshire 2026-05 submi… E230… Asian          38 E23000010      Asian    
#> 5 west-yorkshire 2026-05 submi… NA    Asian           1 NA             Asian    
#> 6 west-yorkshire 2026-06 submi… E230… Asian          44 E23000010      Asian    
#> # ℹ 1 more variable: months_submitted <int>
```
