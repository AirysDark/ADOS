#!/usr/bin/env python3
import argparse, hashlib, json
from pathlib import Path

TARGETS = {
    "rpi3-32": ("rpi3b", "arm32"),
    "rpi3-64": ("rpi3b", "arm64"),
    "rpi3b-b0-32": ("rpi3-frankenstein", "arm32"),
    "rpi3b-b0-64": ("rpi3-frankenstein", "arm64"),
    "rpi3bplus-32": ("rpi3bplus", "arm32"),
    "rpi3bplus-64": ("rpi3bplus", "arm64"),
    "rpi4-32": ("rpi4", "arm32"),
    "rpi4-64": ("rpi4", "arm64"),
}
KERNEL_REPO = "https://github.com/AirysDark/linux.git"
KERNEL_BRANCH = "rpi-6.12.y"
KERNEL_COMMIT = "43c132e8863c3bff3647033b6a7d2bf87b15501c"

def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--artifacts", default="output")
    p.add_argument("--release", required=True)
    p.add_argument("--base-url", required=True)
    p.add_argument("--output", default="output/ADOS-release-manifest.json")
    a = p.parse_args()
    root = Path(a.artifacts)
    profiles = {x: {"arm32": None, "arm64": None} for x in ("rpi3b","rpi3-frankenstein","rpi3bplus","rpi4")}
    missing = []
    for target, (profile, arch) in TARGETS.items():
        name = f"ADOS-{target}.img.xz"
        path = root / name
        if not path.is_file():
            missing.append(name)
            continue
        profiles[profile][arch] = {
            "target": target,
            "url": a.base_url.rstrip("/") + "/" + name,
            "sha256": digest(path),
            "size": path.stat().st_size,
        }
    if missing:
        raise SystemExit("missing required artifacts: " + ", ".join(missing))
    doc = {
        "schema": "ados.release-manifest.v1",
        "release": a.release,
        "kernel": {"repository": KERNEL_REPO, "branch": KERNEL_BRANCH, "commit": KERNEL_COMMIT},
        "profiles": profiles,
    }
    out = Path(a.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n")

if __name__ == "__main__":
    main()
