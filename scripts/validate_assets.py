"""Validate Unity asset integrity without launching Unity or using dependencies."""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


BUILTIN_GUIDS = {
    "00000000000000000000000000000000",
    "0000000000000000e000000000000000",
    "0000000000000000f000000000000000",
}
REFERENCE_EXTENSIONS = {".meta", ".mat", ".prefab", ".unity", ".asset"}
GUID = re.compile(r"^guid: ([0-9a-f]{32})\s*$", re.MULTILINE)
REFERENCE = re.compile(r"\bguid:\s*([0-9a-fA-F]{32})\b")


def validate(root: Path) -> tuple[list[str], int, int]:
    assets = root / "Assets" / "HinasakiShaders"
    errors: list[str] = []
    if not assets.is_dir():
        return ["Missing Assets/HinasakiShaders directory"], 0, 0
    entries = [assets, *sorted(assets.rglob("*"))]
    meta_files = [Path(str(assets) + ".meta"), *sorted(assets.rglob("*.meta"))]
    guids: dict[str, Path] = {}
    asset_count = 0
    reference_count = 0

    def label(path: Path) -> str:
        return path.relative_to(root).as_posix()

    for path in entries:
        if path.suffix == ".meta":
            continue
        if path.is_file():
            asset_count += 1
        if not Path(str(path) + ".meta").is_file():
            errors.append(f"Missing .meta: {label(path)}")

    for meta in meta_files:
        if not meta.is_file():
            continue
        target = meta.with_suffix("")
        if not target.exists():
            errors.append(f"Orphan .meta: {label(meta)}")
        text = meta.read_text(encoding="utf-8-sig")
        matches = GUID.findall(text)
        if len(matches) != 1:
            errors.append(f"Expected one valid asset GUID: {label(meta)}")
            continue
        guid = matches[0]
        if guid in BUILTIN_GUIDS:
            errors.append(f"Reserved GUID used by asset: {label(meta)}")
        if guid in guids:
            errors.append(f"Duplicate GUID: {label(meta)} and {label(guids[guid])}")
        else:
            guids[guid] = meta
        folder_flag = re.search(r"^folderAsset:\s*yes\s*$", text, re.MULTILINE)
        if target.exists() and bool(folder_flag) != target.is_dir():
            errors.append(f"Folder metadata mismatch: {label(meta)}")

    for path in [*entries, Path(str(assets) + ".meta")]:
        if not path.is_file() or path.suffix not in REFERENCE_EXTENSIONS:
            continue
        for guid in REFERENCE.findall(path.read_text(encoding="utf-8-sig")):
            reference_count += 1
            guid = guid.lower()
            if guid not in guids and guid not in BUILTIN_GUIDS:
                errors.append(f"Unresolved GUID {guid}: {label(path)}")

    for notice in ["LICENSE", "NOTICE"]:
        source = root / notice
        bundled = assets / (notice + ".txt")
        if not source.is_file() or not bundled.is_file():
            errors.append(f"Missing root or bundled {notice}")
        elif source.read_text(encoding="utf-8-sig") != bundled.read_text(encoding="utf-8-sig"):
            errors.append(f"Bundled {notice} differs from repository copy")
    return errors, asset_count, reference_count


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    errors, count, references = validate(args.root.resolve())
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print(f"Validated {count} asset files and {references} GUID references.")
    print("Metadata pairs, unique GUIDs, references, and bundled notices are valid.")
    print("This check does not compile shaders or verify rendering in Unity.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
