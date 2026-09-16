"""Rebuild source extracts from explicitly downloaded, unmodified originals."""
import csv
import gzip
import json
import re
import zipfile
import xml.etree.ElementTree as ET

NS = {
    "t": "urn:oasis:names:tc:opendocument:xmlns:table:1.0",
    "x": "urn:oasis:names:tc:opendocument:xmlns:text:1.0",
}


def write_csv(path, rows):
    with open(path, "w", newline="", encoding="utf-8") as target:
        writer = csv.DictWriter(target, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


root = ET.fromstring(zipfile.ZipFile("data-raw/sources/ppap-2025.ods")
                     .read("content.xml"))
table = next(t for t in root.findall(".//t:table", NS)
             if t.get("{" + NS["t"] + "}name") == "SS_20")
forces = json.load(open("inst/extdata/forces.json", encoding="utf-8"))
names = {f["id"].replace("-", " "): f["id"] for f in forces}
names.update({"london, city of": "city-of-london",
              "metropolitan police": "metropolitan",
              "british transport police": "british-transport-police"})
rows = []
for row in table.findall("t:table-row", NS)[6:]:
    cells = []
    for cell in row.findall("t:table-cell", NS):
        text = " | ".join("".join(p.itertext())
                          for p in cell.findall(".//x:p", NS))
        repeats = min(40, int(cell.get(
            "{" + NS["t"] + "}number-columns-repeated", "1")))
        cells += [text] * repeats
    force = names.get(cells[1].lower().replace("-", " "))
    if force:
        rows.append(dict(
            force_id=force, pfa_code=cells[0], year_end=2025,
            published_total=int(cells[7].replace(",", "")),
            scope="All relevant legislation; SS_20", retrieved="2026-09-16",
            source="https://www.gov.uk/government/statistics/"
                   "stop-and-search-arrests-and-mental-health-detentions-march-2025"))
assert len(rows) == 44, len(rows)
assert sum(row["published_total"] for row in rows) == 528582
write_csv("inst/extdata/ppap-totals.csv", rows)

text = open("data-raw/sources/changelog.html", encoding="utf-8").read()
with gzip.open("inst/extdata/changelog-2026-09-16.html.gz", "wb") as target:
    target.write(text.encode())
rows = []
for month, name in [("2026-05", "May"), ("2026-06", "June"), ("2026-07", "July")]:
    pattern = (r"<li>(Dyfed-Powys Police: Stop and search data not provided for "
               + name + r" 2026\..*?)</li>")
    note = re.search(pattern, text).group(1)
    rows.append(dict(force_id="dyfed-powys", month=month, note=note,
                     issue="TRUE", retrieved="2026-09-16"))
write_csv("inst/extdata/changelog.csv", rows)
