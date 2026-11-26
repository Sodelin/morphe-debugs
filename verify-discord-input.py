"""Check original Discord APKs inside a split archive before patching."""
import hashlib
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from zipfile import BadZipFile, ZipFile

EXPECTED_SIGNER = "3c39d23cf9367849a5c699395647fe0e5bfea5a1f1f40d8c717ddc70f8bfa113"
EXPECTED_BUNDLE = "0f2e1735fc0ed5d7f7068aaae8cfb603987a346584b3eea0fd8790df38e2a8b2"


def inspect(archive):
    splits = set()
    split_types = set()
    bases = 0
    with ZipFile(archive) as source, tempfile.TemporaryDirectory(dir=".cache") as scratch:
        entries = [item for item in source.infolist() if item.filename.endswith(".apk")]
        if not entries or len({item.filename for item in entries}) != len(entries):
            raise ValueError("Missing or duplicate APK archive entries")
        apk = Path(scratch) / "module.apk"
        for item in entries:
            with source.open(item) as installed, apk.open("wb") as local:
                shutil.copyfileobj(installed, local)
            cert = subprocess.check_output(["apksigner", "verify", "--print-certs", apk], text=True)
            digests = set(re.findall(r"(?mi)^(?!Source Stamp).*Signer: certificate SHA-256 digest: ([a-f0-9]+)$", cert))
            if digests != {EXPECTED_SIGNER}:
                raise ValueError(f"Unexpected signing certificate: {item.filename}")
            badging = subprocess.check_output(["aapt", "dump", "badging", apk], text=True)
            if not re.search(r"(?m)^package: name='com\.discord' versionCode='350008' ", badging):
                raise ValueError(f"Wrong Discord package or version: {item.filename}")
            manifest = subprocess.check_output(
                ["aapt", "dump", "xmltree", apk, "AndroidManifest.xml"], text=True
            )
            split = re.search(r'(?m)^\s+A: split="([^"]+)"', manifest)
            if split:
                name = split[1]
                if name in splits:
                    raise ValueError(f"Duplicate split ID: {name}")
                splits.add(name)
                types = re.search(r'(?m)^\s+A: android:splitTypes\([^)]*\)="([^"]*)"', manifest)
                if types:
                    split_types.update(types[1].split(","))
            else:
                bases += 1
                with ZipFile(apk) as base, base.open("assets/index.android.bundle") as bundle:
                    if hashlib.file_digest(bundle, "sha256").hexdigest() != EXPECTED_BUNDLE:
                        raise ValueError("Discord base does not match the Venus input guard")
    if bases != 1:
        raise ValueError("Expected exactly one original base APK")
    if not {"base__abi", "base__density"} <= split_types or "config.arm64_v8a" not in splits:
        raise ValueError("Missing matching ARM64 ABI or density split")
    print("Verified original Discord 350008 with ARM64 and density splits")


if __name__ == "__main__":
    try:
        inspect(Path(sys.argv[1]))
    except (BadZipFile, IndexError, KeyError, OSError, subprocess.CalledProcessError, ValueError) as error:
        sys.exit(str(error))
