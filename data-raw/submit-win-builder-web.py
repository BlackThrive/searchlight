"""Explicit HTTPS win-builder check upload, retaining earlier receipts."""

import argparse
import datetime
import hashlib
import json
import urllib.request
import uuid
from html.parser import HTMLParser
from pathlib import Path


class Form(HTMLParser):
    def __init__(self):
        super().__init__()
        self.hidden = {}
        self.text = []
        self.labels = {}
        self.active_label = None

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "input" and attrs.get("type") == "hidden":
            self.hidden[attrs["name"]] = attrs.get("value", "")
        if tag == "span" and attrs.get("id") == "Label2":
            self.active_label = "Label2"
            self.labels["Label2"] = []

    def handle_endtag(self, tag):
        if tag == "span":
            self.active_label = None

    def handle_data(self, data):
        if data.strip():
            self.text.append(data.strip())
            if self.active_label:
                self.labels[self.active_label].append(data.strip())


root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--artifact-manifest")
parser.add_argument("--receipt", default="inst/validation/M5-win-builder.json")
args = parser.parse_args()
receipt_path = root / args.receipt
previous = (json.loads(receipt_path.read_text())
            if receipt_path.exists() else None)
if args.artifact_manifest:
    artifact = json.loads((root / args.artifact_manifest).read_text())
    source = root / artifact["file"]
    source_sha256 = artifact["sha256"]
    assert not (previous and previous.get("source_sha256") == source_sha256
                and previous["status"] != "submission not confirmed"), (
                    "This artifact already has a receipt; inspect it before retrying.")
else:
    assert previous and previous["status"] == "submission not confirmed"
    source = root / previous["source_file"]
    source_sha256 = previous["source_sha256"]
payload = source.read_bytes()
assert hashlib.sha256(payload).hexdigest() == source_sha256
url = "https://win-builder.r-project.org/upload.aspx"
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor())
with opener.open(url, timeout=45) as response:
    form = Form()
    form.feed(response.read().decode("utf-8"))
assert {"__VIEWSTATE", "__EVENTVALIDATION"} <= form.hidden.keys()
boundary = "----searchlight-" + uuid.uuid4().hex
parts = []
for name, value in {**form.hidden, "Button2": "Upload File"}.items():
    parts.append((f"--{boundary}\r\nContent-Disposition: form-data; "
                  f'name="{name}"\r\n\r\n{value}\r\n').encode())
parts.append((f"--{boundary}\r\nContent-Disposition: form-data; "
              f'name="FileUpload2"; filename="{source.name}"\r\n'
              "Content-Type: application/gzip\r\n\r\n").encode())
parts.extend([payload, f"\r\n--{boundary}--\r\n".encode()])
request = urllib.request.Request(url, data=b"".join(parts), headers={
    "Content-Type": f"multipart/form-data; boundary={boundary}"
})
receipt = {
    "attempted": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "service": url, "target": "R-devel", "transport": "HTTPS",
    "source_file": source.name, "source_sha256": source_sha256,
    "source_bytes": len(payload), "check_verified": False,
    "previous_attempt": previous,
}
try:
    with opener.open(request, timeout=60) as response:
        html = response.read().decode("utf-8")
        (root / "data-raw/work/win-builder-response.html").write_text(
            html, encoding="utf-8")
        result = Form()
        result.feed(html)
        confirmation = " ".join(result.labels.get("Label2", []))
        acknowledged = (f"File name: {source.name}" in confirmation
                        and f"File Size: {len(payload)} bytes" in confirmation)
        receipt.update(status=("uploaded via HTTPS; check result pending"
                               if acknowledged else
                               "HTTP response received; inspect receipt"),
                       http_status=response.status,
                       response_confirmation=confirmation,
                       result_delivery="DESCRIPTION maintainer email")
        print("\n".join(result.text))
except Exception as error:
    receipt.update(status="submission not confirmed", reason=str(error))
finally:
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
