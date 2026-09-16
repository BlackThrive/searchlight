"""Submit the locally checked source artifact to the requested R-devel service.

Run explicitly after release-finalise.R. This does not submit to CRAN.
Win-builder sends its result URL to the DESCRIPTION maintainer address.
"""

import datetime
import ftplib
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
artifact = root / "searchlight_0.1.0.tar.gz"
local_check = json.loads((root / "inst/validation/M5-size.json").read_text())
assert all(local_check[key] == 0 for key in
           ("check_errors", "check_warnings", "check_notes"))
metadata = json.loads((root / "data-raw/work/source-artifact.json").read_text())
checksum = hashlib.sha256(artifact.read_bytes()).hexdigest()
assert checksum == metadata["sha256"]
receipt = {
    "attempted": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "service": "https://win-builder.r-project.org/",
    "target": "R-devel",
    "source_file": artifact.name,
    "source_sha256": checksum,
    "source_bytes": artifact.stat().st_size,
    "check_verified": False,
    "transport": "FTP",
    "transfer_started": False,
}
try:
    with ftplib.FTP("win-builder.r-project.org", timeout=45) as ftp:
        ftp.login("anonymous", "mustapha.wasseja.mohammed@gmail.com")
        ftp.set_pasv(True)
        ftp.cwd("R-devel")
        with artifact.open("rb") as source:
            receipt["transfer_started"] = True
            response = ftp.storbinary(f"STOR {artifact.name}", source)
        receipt.update(status="submitted; result pending", response=response,
                       result_delivery="DESCRIPTION maintainer email")
except Exception as error:
    receipt.update(status="submission not confirmed", reason=str(error))
finally:
    path = root / "inst/validation/M5-win-builder.json"
    path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(receipt, indent=2))
