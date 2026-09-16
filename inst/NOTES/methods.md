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

Rates, sensitivity and inference definitions will be added with their tested
implementations. The current development package does not claim those methods
are implemented or validated.
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
