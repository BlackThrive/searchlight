# Estimate a multivariate spatial stop-rate disparity surface

Uses CARBayes MVS.CARleroux with two Poisson responses and a matrix of
log population-time offsets. Each ethnicity has its own spatial effect
phi_ig. The equivalent shared/contrast decomposition is
u_i=(phi_ir+phi_ic)/2, v_ir=(phi_ir-phi_ic)/2 and v_ic=-v_ir. These
components have the covariance induced by the multivariate prior; they
are not separately independent priors. The full posterior ratio is
exp(alpha_c-alpha_r+phi_ic-phi_ir). Smoothing stabilises under stated
assumptions; it cannot repair exposure, missing ethnicity, missing
submissions or anonymised location errors.

## Usage

``` r
sl_spatial_disparity(
  counts,
  population,
  boundaries,
  reference = "White",
  comparison = "Black",
  backend = c("carbayes", "inla"),
  burnin = 2000,
  n.sample = 12000,
  thin = 10,
  chains = 2,
  k = 2,
  adjacency = NULL,
  boundary_threshold = 0.2,
  seed = 1,
  ...
)
```

## Arguments

- counts:

  Marginal event counts with a valid contract.

- population:

  Compatible marginal ethnicity exposure table.

- boundaries:

  sf polygons with geography_code.

- reference, comparison:

  Known self-defined ethnicity groups.

- backend:

  CARBayes. INLA is explicitly deferred beyond version 0.1.0.

- burnin, n.sample, thin:

  MCMC controls per chain, including burn-in in n.sample.

- chains:

  Number of independent chains, at least two, run on one core.

- k:

  Additional ratio threshold for exceedance probability.

- adjacency:

  Optional symmetric adjacency matrix named with geography codes.
  Otherwise rook adjacency is used; islands require an explicit
  decision.

- boundary_threshold:

  Warn if the assigned boundary-sensitive share exceeds this proportion
  (default 0.2).

- seed:

  Reproducible seed, restored on exit.

- ...:

  Prior and sampler arguments for MVS.CARleroux, such as rho or MALA.

## Value

An sl_spatial tibble with 90/95 percent intervals, exceedance
probabilities, crude ratios, rank-normalised R-hat and bulk/tail ESS.
Joint posterior draws, fitted model, diagnostics and boundaries are
attributes.

## See also

[`sl_simulate()`](https://blackthrive.github.io/searchlight/reference/sl_simulate.md),
[`sl_spatial_map()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_map.md),
[`sl_ranking_stability()`](https://blackthrive.github.io/searchlight/reference/sl_ranking_stability.md)

Other inference:
[`sl_count_model()`](https://blackthrive.github.io/searchlight/reference/sl_count_model.md),
[`sl_hit_rates()`](https://blackthrive.github.io/searchlight/reference/sl_hit_rates.md),
[`sl_simulate()`](https://blackthrive.github.io/searchlight/reference/sl_simulate.md),
[`sl_spatial_map()`](https://blackthrive.github.io/searchlight/reference/sl_spatial_map.md),
[`sl_veil_of_darkness()`](https://blackthrive.github.io/searchlight/reference/sl_veil_of_darkness.md)

## Examples

``` r
# A precomputed synthetic fit avoids MCMC in installed examples.
path <- system.file("extdata", "example-spatial.rds",
  package = "searchlight"
)
if (nzchar(path)) {
  fit <- readRDS(path)
  head(fit)
  head(sl_spatial_map(fit))
}
#> Simple feature collection with 6 features and 17 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4e+05 ymin: 3e+05 xmax: 405000 ymax: 302000
#> Projected CRS: OSGB36 / British National Grid
#>   geography_code reference comparison     ratio credible_low_90
#> 1        SIM0001     White      Black 0.7861381       0.4842667
#> 2        SIM0002     White      Black 1.1014396       0.7400085
#> 3        SIM0003     White      Black 1.6685917       1.1774143
#> 4        SIM0004     White      Black 2.6745578       1.9197267
#> 5        SIM0005     White      Black 5.2500392       3.8530215
#> 6        SIM0006     White      Black 0.7652769       0.5148710
#>   credible_high_90 credible_low_95 credible_high_95 probability_above_1
#> 1         1.212122       0.4412384         1.313809              0.1830
#> 2         1.626751       0.6885038         1.761656              0.6550
#> 3         2.318432       1.1100240         2.491010              0.9920
#> 4         3.675372       1.7760321         3.910899              1.0000
#> 5         7.338089       3.6863251         7.853770              1.0000
#> 6         1.077468       0.4696151         1.139070              0.1065
#>   probability_above_k k crude_ratio unknown_events     rhat ess_bulk ess_tail
#> 1               0.000 2   0.6250000              0 1.004023  971.495 1260.724
#> 2               0.006 2   0.9016393              0 1.000098 1148.122 1321.585
#> 3               0.203 2   1.5833333              0 1.000795 1295.299 1780.364
#> 4               0.923 2   2.5454545              0 1.000154 1331.485 1582.539
#> 5               1.000 2   6.2162162              0 1.001120 1397.858 1716.206
#> 6               0.000 2   0.6355932              0 1.001286 1042.901 1315.013
#>   converged                       geometry
#> 1      TRUE POLYGON ((4e+05 3e+05, 4010...
#> 2      TRUE POLYGON ((401000 3e+05, 402...
#> 3      TRUE POLYGON ((402000 3e+05, 403...
#> 4      TRUE POLYGON ((403000 3e+05, 404...
#> 5      TRUE POLYGON ((404000 3e+05, 405...
#> 6      TRUE POLYGON ((4e+05 301000, 401...
```
