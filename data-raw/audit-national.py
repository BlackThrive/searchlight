"""Independent raw-CSV audit, without loading searchlight or another package."""
from collections import Counter
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo
import csv
import json
import re

root = Path(".cache/snapshots/2026-07")
labels = Counter()
coordinates = set()
force_labels = Counter()
files = []
crossings = []
bad_months = []
for path in sorted(root.glob("*/*-stop-and-search.csv")):
    match = re.fullmatch(r"(\d{4}-\d{2})-(.+)-stop-and-search.csv", path.name)
    month, force = match.groups()
    if not "2025-08" <= month <= "2026-07" or force == "northern-ireland":
        continue
    count = missing_coordinates = 0
    with path.open(encoding="utf-8-sig", newline="") as source:
        for row in csv.DictReader(source):
            count += 1
            label = row["Self-defined ethnicity"]
            labels[label] += 1
            force_labels[force, month, label] += 1
            lat, lon = row["Latitude"], row["Longitude"]
            if lat and lon:
                coordinates.add((lat, lon))
            else:
                missing_coordinates += 1
            stamp = row["Date"]
            if stamp:
                value = datetime.fromisoformat(stamp)
                local_month = value.astimezone(ZoneInfo("Europe/London")).strftime("%Y-%m")
                if local_month != month:
                    crossings.append((force, month, stamp, local_month))
                    if stamp[:7] != month:
                        bad_months.append((force, month, stamp, local_month))
    files.append((force, month, count, missing_coordinates))

output = Path("inst/validation")
for name, header, rows in (
    ("national-raw-labels.csv", ("source_label", "events"), labels.items()),
    ("national-raw-coverage.csv", ("force_id", "month", "events", "missing_coordinates"), files),
    ("national-month-crossings.csv", ("force_id", "month", "date_raw", "london_month"), crossings),
    ("national-force-month-labels.csv", ("force_id", "month", "source_label", "events"),
     ((*key, value) for key, value in force_labels.items())),
):
    with (output / name).open("w", encoding="utf-8", newline="") as target:
        writer = csv.writer(target)
        writer.writerow(header)
        writer.writerows(rows)

audit = dict(files=len(files), events=sum(labels.values()),
             distinct_coordinate_strings=len(coordinates),
             london_month_crossings=len(crossings), invalid_months=bad_months,
             method="Python standard-library CSV audit; no searchlight code")
(output / "national-raw-audit.json").write_text(json.dumps(audit, indent=2), encoding="utf-8")
print(json.dumps(audit, indent=2))
