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
