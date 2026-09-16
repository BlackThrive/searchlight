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
