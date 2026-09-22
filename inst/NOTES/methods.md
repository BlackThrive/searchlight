# Method definitions and interpretation

## Provenance and revisions

The observation unit is a recorded search event. Rows that look identical may
represent separate events and are never removed to reconcile archives. A
force-month is selected as one whole CSV, with alternatives, hashes, row counts,
and the selection rule retained in the ingestion contract.

The archive index describes rolling snapshots. Absence of a force-month CSV is
missing submission evidence, not evidence of zero events. An existing CSV with
only a header is an observed empty submission; those two states remain distinct.

Publisher MD5 checks downloaded bytes against the published checksum. Locally
computed SHA-256 checks later integrity; it does not independently authenticate
the publisher. The real sample retains the raw CSV contents in gzip form and
records hashes of both representations.

## Measurement

Self-defined ethnicity is mapped to Census 2021 categories using the versioned
PACE 2023 crosswalk. Unknown, blank and refused values remain Unknown. Perceived
ethnicity from the officer is a separate measure with its own variable. An
Unknown police category does not provide a Census population denominator.

Any action, arrest and outcome linked to the search object are separate fields.
A missing outcome is not a negative outcome. Contradictory source fields remain
visible instead of being silently reconciled.

Times retain supplied offsets and are displayed in Europe/London. Location
coordinates are anonymised snap points; later spatial assignment is assignment
of those points, not recovery of the original location.

## Geography, exposure and audit

Point assignment intersects anonymised published coordinates with valid ONS
polygons in British National Grid (EPSG:27700). Distances are from the reported
point to the assigned polygon boundary. A distance below 50 m is a sensitivity
flag, not a probability that an event belongs in another area. Published
locations are snap points and can have systematic error. Polygon generalisation
and coastline clipping introduce additional limitations. Missing or out-of-range
coordinates retain NA assignment; overlapping polygon matches are flagged.
Boundary-sensitive shares use assigned events with measured distances. Missing
coordinate and unassigned shares use all supplied events, so the denominators
of these diagnostics differ and remain explicit.

Population exposure is usual residents at the Census 2021 reference date.
Ethnicity derives exclusively from self-defined records; officer-defined
ethnicity remains separate. Census has no Unknown ethnicity denominator.
RM032 cross-tab cells retain age and sex, harmonised only by summing disjoint
published categories. Census sex and police-recorded gender are not equivalent
measurements. Changed geography needs a justified exposure, not a join based
only on a familiar geography code. Different Census tables may have small
disclosure-control inconsistencies and are not forced to agree.

Submission status comes from original selected CSVs. An absent CSV is missing
with NA count. A present zero-row CSV represents zero recorded events, with a
possible partial-submission flag if it is anomalously low. The reference median
uses submitted files from the preceding twelve calendar months, excluding the
current month. Counts below 20% of that median and unresolved changelog issues
are partial_suspected. Differing revision counts are refreshed unless partial
suspicion takes precedence. Filtering records never changes source counts.

The time-quality screen uses the maximum of source-clock and London-clock
midnight shares, and requires it below 5%, with no missing timestamps. This
guards against date-only UTC strings moving to 01:00 in British summer time.
Passing is a necessary screening condition, not evidence of accurate times.
The force-level range of these monthly shares describes temporal stability.

Home Office financial-year benchmarks require all twelve April-March months
and all ingested rows in those months. Missing, suspected partial and filtered
years withhold ratios. Even complete years can differ because of included
powers, person/vehicle reporting, source revisions and publication cut-offs.

## Event rates and sensitivity

For count N, resident population P and m submitted months, exposure E is P*m/12
person-years. The annualised event rate is 1000*N/E; period_rate is 1000*N/P.
Missing submission months have NA counts and zero exposure. Partial submissions
remain flagged and estimate reported events only. Analysis subsets retain the
source coverage window unless months are selected explicitly. The complete area
universe must be supplied or retained in the contract to represent zero-event
areas. An observed-only universe is labelled as such.

The comparison/reference stop-rate ratio is (Nc/Ec)/(Nr/Er), not a probability
ratio for people. Poisson inference uses the exact conditional two-count interval.
Zero counts need no arbitrary pseudocount; both groups zero is uninformative.
Quasi-Poisson uses a Student t interval with residual degrees of freedom; negative
binomial uses a log-scale Wald interval. Both need replicated cells and positive
group totals. Pearson residual dispersion is reported where degrees of freedom
permit. Model intervals remain conditional on the exposure and independence
assumptions, and are not adjusted for multiple comparisons.

For U unknown-ethnicity events, marginal extreme ratios are
L = (Nc/Ec)/((Nr+U)/Er) and H = ((Nc+U)/Ec)/(Nr/Er).
The fraction allocated to the comparison group at equality is
q = [Ec*(Nr+U)-Er*Nc]/[U*(Er+Ec)]. It is not clipped to [0,1]: the separate
feasibility flag indicates whether equality is attainable. Proportional allocation
uses every known ethnicity, while force-object MAR estimates known shares within
force and search-object strata. MAR without an object variable is labelled
unavailable; a stratum containing unknown events but no known ethnicity is refused.
Applying these pooled shares locally also assumes that the force/object known
composition applies to each recipient area and month. Missingness depending only
on force/object does not itself imply that composition is homogeneous across
areas; the scenario can still distort local disparity when it is not.
The extrema bound reallocation of recorded events, not latent population-rate
truth under sampling variation or missing submissions.

Alternative exposure scenarios must have identical geography, classification and
cell keys. Their range contains scenario point estimates only. Sampling intervals
are conditional on each scenario and remain separately labelled.

Direct standardisation uses the same age-sex weights for every ethnicity: either
all England and Wales residents or the summed study population. Weighted rates
sum stratum event counts divided by submitted population-time. Required strata
with zero population make the standardised result undefined. Unknown age, sex and
ethnicity exclusions are counted per area. Confidence limits weight Bonferroni
simultaneous exact Poisson stratum intervals; these are conservative, including
for zero events, and do not quantify denominator or measurement uncertainty.

Rank bootstrap draws counts from fitted Poisson/negative-binomial cell means,
recomputes ratios and ranks the largest first. It requires positive observed
group totals, and omits draws with an undefined zero/zero ratio, reporting the
effective draw count. Posterior ranks use supplied joint draws. Pairwise ordering
probabilities above 0.95 (or below 0.05) are flagged, without a simultaneous
multiple-comparison guarantee. Scenarios are evaluated separately. Rank intervals
and assumption ranges are never pooled into one uncertainty distribution.

## Count and spatial inference

Count regression uses log exposure offsets with Poisson or negative-binomial
likelihoods; optional group random effects use lme4. Coefficient intervals are
Wald intervals on the log scale, exponentiated. Population offsets incorporate
submitted months when available; an alternative exposure column must already
cover the observation period. Invalid exposures, unknown ethnicity and incomplete
model cells are counted as exclusions. Pearson dispersion and Moran's I on mean
area residuals are diagnostic, not automatic model corrections. The Moran
permutation p-value ignores uncertainty from model fitting and is exploratory.

For spatial inference, N_ig ~ Poisson(E_ig*exp(alpha_g+phi_ig)). The MCAR prior
has covariance Sigma across groups and a Leroux spatial precision Q(rho) =
rho*(D-W)+(1-rho)*I across areas. For a pair of groups define u_i as their mean
field and v_ig as the deviation from that mean. Then log(theta_ig)=alpha_g+u_i+v_ig
and the disparity surface exp(alpha_c-alpha_r+v_ic-v_ir) uses the full joint
posterior. This constrained shared/contrast representation is equivalent to the
fitted bivariate MCAR and does not assert independent component priors.

Rook adjacency is binary and symmetric. Unconnected areas require an explicit
decision rather than silently invented neighbours. The documented CARBayes
priors apply unless overridden, and arguments are recorded with the fit. Two
chains and rank-normalised split R-hat plus bulk/tail ESS are retained. The
diagnostic threshold is R-hat <=1.01 and both ESS >=400; warnings are not suppressed
in the public function. Exceedance probabilities and 90/95% credible intervals
condition on the model and exposure, and are not missing-data assumption ranges.
Smoothing can blur local jumps or impose prior structure when populations are
small. The replicated simulation vignette reports error, coverage, rank recovery
and individual areas made worse by smoothing, not a claim of general correction.

## Outcome and darkness diagnostics

Outcome proportions divide successes by searches with the particular outcome
observed. Wilson limits invert the binomial score test. Three source outcomes
remain separate; NA is not a failure. Pairwise logistic comparisons condition on
searches with known ethnicity and outcome, adjusting force and object fixed
effects. Constant controls are labelled, and numerically unstable or separated
fits have intervals withheld. Hit rates condition on selection into being
searched; infra-marginality and unobserved risk distributions prevent a simple
interpretation as discrimination. Neither equality nor inequality of hit rates
alone establishes equal or unequal treatment thresholds.

Darkness models additionally require the contract's force-month time gate. The
annual minimum and maximum local evening twilight at each observed location
define the intertwilight clock-time window. Civil darkness begins at dusk and
sunset-to-dusk rows are removed; the alternative sunset definition is explicit.
Logistic comparison-group membership is modelled by darkness, natural cubic
clock-time spline (3 df when enough times exist), weekday, calendar month and
force. Constant factors are omitted. The DST design restricts to +/-3 weeks
around Europe/London clock changes and adds a linear day-distance term plus
transition fixed effects where they vary. It is a local conditional association,
not an automatic causal discontinuity estimate. Record each exclusion and the
final design rows. Missing locations are never assigned to a force centroid.

The method originated for vehicle stops. Applying it to pedestrian searches
requires defensible assumptions about pre-stop visibility, activity by ethnicity,
police deployment, reporting, time accuracy and residual daylight overlap. These
assumptions are exposed in every result. Repeated events and unmeasured selection
can violate independent-event inference. An undefined result is not evidence of
no disparity.

## References and their roles

* Ratcliffe, J. H. and Hyland, S. S. (2025). Police stops and naive denominators.
  *Crime Science* 14, 10. [DOI](https://doi.org/10.1186/s40163-025-00252-y).
  Motivates explicit exposure scenarios. Alternative policing/activity measures
  can themselves reflect selection and policy; no denominator is declared neutral.
* Manski, C. F. (2003). *Partial Identification of Probability Distributions*.
  Springer. [DOI](https://doi.org/10.1007/b97478). Provides the partial-identification
  perspective. The package's finite-event allocation extrema do not automatically
  bound a latent population parameter under sampling variation.
* Knorr-Held, L. and Best, N. G. (2001). A shared component model for detecting
  joint and selective clustering of two diseases. *JRSS A* 164(1), 73-85.
  [DOI](https://doi.org/10.1111/1467-985X.00187). Context for separating shared and
  group-specific spatial structure; the fitted bivariate MCAR parameterisation
  and covariance assumptions are stated above.
* Lee, D. (2013). CARBayes: An R package for Bayesian spatial modeling with
  conditional autoregressive priors. *Journal of Statistical Software* 55(13).
  [Article](https://www.jstatsoft.org/article/view/v055i13). Backend documentation
  is verified against CARBayes 6.1.1 for the actual multivariate interface.
* Riebler, A., Sorbye, S. H., Simpson, D. and Rue, H. (2016). An intuitive Bayesian
  spatial model for disease mapping that accounts for scaling. *Statistical
  Methods in Medical Research* 25(4), 1145-1165.
  [DOI](https://doi.org/10.1177/0962280216660421). BYM2 background; that backend is
  deferred beyond 0.1.0 and is not a description of the current MCAR prior.
* Grogger, J. and Ridgeway, G. (2006). Testing for racial profiling in traffic
  stops from behind a veil of darkness. *JASA* 101(475):878-887.
  doi:10.1198/016214506000000168. Listed in
  [selected publications by Ridgeway](https://crim.sas.upenn.edu/people/greg-ridgeway).
  The evening overlap motivates the darkness design, subject to the transfer
  assumptions for pedestrian search stated above.
* Knowles, J., Persico, N. and Todd, P. (2001). Racial bias in motor vehicle
  searches. *Journal of Political Economy* 109(1).
  [DOI](https://doi.org/10.1086/318603). Outcome-test context; reported hit-rate
  associations alone do not identify search thresholds or discrimination.
* Miles-Wilson, J. and Okoroji, C. (2026). policedatR: a comprehensive R package
  for stop and search data in England and Wales. *Crime Science* 15, 11.
  [DOI](https://doi.org/10.1186/s40163-025-00266-6). Cited only to contrast related
  work with this package's bulk-archive, local-geography and count/exposure design.
  No implementation from that package, ExtractSS or ukpolice was consulted.
* Home Office (2025). Police powers and procedures, England and Wales, year
  ending March 2025. [Publication](https://www.gov.uk/government/statistics/stop-and-search-arrests-and-mental-health-detentions-march-2025).
  Published force totals are a scope-sensitive benchmark, not a correction factor.
* Office for National Statistics (2023). Ethnic group classifications: Census
  2021. [Classification](https://www.ons.gov.uk/census/census2021dictionary/variablesbytopic/ethnicgroupnationalidentitylanguageandreligionvariablescensus2021/ethnicgroup/classifications).
  Supplies the Census categories. Unknown police ethnicity has no corresponding
  resident-population denominator.
