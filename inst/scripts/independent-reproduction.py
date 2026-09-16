"""Independent force-level reference using Python CSV and Census source labels.

Run explicitly from the repository root after data-raw/audit-national.py.
Downloads public ONS/NOMIS inputs only when absent from the explicit local cache.
No searchlight R function or classification table is used to calculate ratios.
"""
from collections import Counter
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen
import csv
import hashlib
import io
import json

cache = Path("data-raw/sources/reproduction")
cache.mkdir(parents=True, exist_ok=True)
out = Path("inst/validation")
sources = []


def fetch(url, name):
    path = cache / name
    if not path.exists():
        request = Request(url, headers={"User-Agent": "searchlight-validation/0.1.0"})
        with urlopen(request, timeout=180) as response:
            path.write_bytes(response.read())
    raw = path.read_bytes()
    sources.append(dict(url=url, file=name, sha256=hashlib.sha256(raw).hexdigest()))
    return raw.decode("utf-8-sig")


def write_csv(name, fields, rows):
    with (out / name).open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


base = "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"
lookup_url = base + "LAD22_CSP22_PFA22_EW_LU/FeatureServer/0/query?" + urlencode(dict(
    where="1=1", outFields="LAD22CD,LAD22NM,PFA22CD,PFA22NM", f="json",
    returnGeometry="false", resultRecordCount=1000, orderByFields="LAD22CD"))
lookup_data = json.loads(fetch(lookup_url, "lad22-pfa22.json"))
assert not lookup_data.get("exceededTransferLimit") and "error" not in lookup_data
lookup = {x["attributes"]["LAD22CD"]: x["attributes"] for x in lookup_data["features"]}
assert len(lookup) > 300 and len({x["PFA22CD"] for x in lookup.values()}) == 43
item = json.loads(fetch(
    "https://www.arcgis.com/sharing/rest/content/items/4206337e432b45f686e29ac31d731765?f=json",
    "lookup-metadata.json"))
license_url = "https://www.ons.gov.uk/methodology/geography/licences"
assert license_url in str(item.get("licenseInfo", ""))
license_text = fetch(license_url, "ons-geography-licences.html")
assert "Lookups (excluding UPRN and postcode lookups)" in license_text
assert "Lookup products are supplied under the Open Government Licence" in license_text

population = Counter()
all_cells = set()
codes = sorted(lookup)
for start in range(0, len(codes), 20):
    selected = codes[start:start + 20]
    url = "https://www.nomisweb.co.uk/api/v01/dataset/NM_2041_1.data.csv?" + urlencode(dict(
        geography=",".join(selected), c2021_eth_20="1...19",
        measures=20100, recordlimit=25000))
    rows = list(csv.DictReader(io.StringIO(fetch(url, f"census-{start:03d}.csv"))))
    assert len(rows) == len(selected) * 19
    assert {r["GEOGRAPHY_CODE"] for r in rows} == set(selected)
    for row in rows:
        key = row["GEOGRAPHY_CODE"], row["C2021_ETH_20_CODE"]
        assert key not in all_cells and row["OBS_STATUS"] == "A"
        all_cells.add(key)
        label = row["C2021_ETH_20_NAME"]
        group = next((group for prefix, group in (
            ("White:", "White"), ("Black,", "Black"), ("Asian,", "Asian"),
            ("Mixed or Multiple ethnic groups:", "Mixed"),
            ("Other ethnic group:", "Other")) if label.startswith(prefix)), None)
        assert group is not None, label
        population[lookup[row["GEOGRAPHY_CODE"]]["PFA22CD"], group] += int(row["OBS_VALUE"])
    print(f"Census LADs read: {min(start + 20, len(codes))}/{len(codes)}", flush=True)

# This source lookup is already bundled independently from ethnicity mapping.
with Path("inst/extdata/ppap-totals.csv").open(encoding="utf-8-sig", newline="") as stream:
    force_codes = {r["force_id"]: r["pfa_code"] for r in csv.DictReader(stream)
                   if r["force_id"] != "british-transport-police"}
assert len(force_codes) == 43
assert set(force_codes.values()) == {key[0] for key in population}

counts = Counter()
present = set()
with (out / "national-force-month-labels.csv").open(encoding="utf-8", newline="") as stream:
    for row in csv.DictReader(stream):
        label = row["source_label"]
        if not label or label == "Other ethnic group - Not stated":
            group = "Unknown"
        else:
            group = next((g for prefix, g in (
                ("White - ", "White"), ("Black/African/Caribbean/Black British - ", "Black"),
                ("Asian/Asian British - ", "Asian"), ("Mixed/Multiple ethnic groups - ", "Mixed"),
                ("Other ethnic group - ", "Other")) if label.startswith(prefix)), None)
            assert group is not None, label
        force, month = row["force_id"], row["month"]
        present.add((force, month))
        counts[force, month, group] += int(row["events"])
months = sorted({month for _, month in present})
assert len(months) == 12 and sum(counts.values()) == 476738
fixture = []
ratios = []
exposures = []
for force, pfa in sorted(force_codes.items()):
    submitted = sum((force, month) in present for month in months)
    group_totals = {g: sum(counts[force, m, g] for m in months)
                    for g in ("White", "Black", "Unknown")}
    for month in months:
        for group in ("Asian", "Black", "Mixed", "White", "Other", "Unknown"):
            available = (force, month) in present
            fixture.append(dict(force_id=force, geography_code=pfa, month=month,
                ethnicity=group, n=counts[force, month, group] if available else "",
                months_submitted=int(available), status="submitted" if available else "missing"))
    white, black = population[pfa, "White"], population[pfa, "Black"]
    reference, comparison = group_totals["White"], group_totals["Black"]
    ratio = (comparison / black) / (reference / white) if submitted and reference else ""
    ratios.append(dict(force_id=force, geography_code=pfa, months_submitted=submitted,
        n_reference=reference if submitted else "", n_comparison=comparison if submitted else "",
        unknown_events=group_totals["Unknown"] if submitted else "",
        population_reference=white, population_comparison=black, ratio=ratio,
        complete_year=submitted == 12))
    for group in ("Asian", "Black", "Mixed", "White", "Other"):
        exposures.append(dict(geography_code=pfa, ethnicity=group, population=population[pfa, group]))
write_csv("reproduction-counts.csv", list(fixture[0]), fixture)
write_csv("reproduction-population.csv", list(exposures[0]), exposures)
write_csv("reproduction-expected.csv", list(ratios[0]), ratios)
(out / "reproduction-manifest.json").write_text(json.dumps(dict(
    method="Independent Python counts from archive labels and Census label prefixes",
    archive_sha256="312e3b1533ac953df07636781588578335113ef918584de4fcdfcb014a69ca16",
    months=months, forces=len(ratios), full_year_forces=sum(r["complete_year"] for r in ratios),
    lad_units=len(lookup), census_cells=len(all_cells), sources=sources,
    scope="43 territorial E&W forces; BTP absent from source force list; NI excluded",
    interpretation="Partial-year ratios refer only to submitted months; missing years are undefined."
), indent=2), encoding="utf-8")
print("Independent reference written", flush=True)
