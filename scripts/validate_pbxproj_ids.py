#!/usr/bin/env python3
"""Validate that PBX object identifiers are defined only once.

This intentionally scans only object definition lines of the form:

    24HEXID /* optional comment */ = {isa = ...};

References to an existing identifier are ignored. The script exits nonzero
when a duplicate definition is found.
"""

from __future__ import annotations

import argparse
import re
import sys
import tempfile
from pathlib import Path


OBJECT_DEFINITION_RE = re.compile(
    r"^\s*([A-Fa-f0-9]{24})\s*(/\*.*?\*/)?\s*=\s*\{"
)


def is_object_definition(lines: list[str], index: int) -> bool:
    line = lines[index]
    if "isa =" in line:
        return True

    for lookahead in range(index + 1, min(len(lines), index + 12)):
        candidate = lines[lookahead]
        if "isa =" in candidate:
            return True
        if candidate.strip().startswith("};"):
            return False

    return False


def collect_object_definitions(path: Path) -> dict[str, list[tuple[int, str, str]]]:
    definitions: dict[str, list[tuple[int, str, str]]] = {}
    lines = path.read_text(encoding="utf-8").splitlines()
    for index, line in enumerate(lines):
        match = OBJECT_DEFINITION_RE.match(line)
        if not match or not is_object_definition(lines, index):
            continue

        object_id = match.group(1).upper()
        comment = (match.group(2) or "").strip()
        definitions.setdefault(object_id, []).append((index + 1, comment, line))

    return definitions


def validate(path: Path) -> int:
    if not path.exists():
        print(f"error: {path} does not exist", file=sys.stderr)
        return 2

    definitions = collect_object_definitions(path)
    duplicates = {
        object_id: entries
        for object_id, entries in definitions.items()
        if len(entries) > 1
    }

    if not duplicates:
        print(f"OK: {path} has {len(definitions)} unique PBX object identifiers.")
        return 0

    print(f"error: duplicate PBX object identifiers in {path}", file=sys.stderr)
    for object_id, entries in sorted(duplicates.items()):
        print(f"{object_id} is defined {len(entries)} times:", file=sys.stderr)
        for line_number, comment, line in entries:
            suffix = f" {comment}" if comment else ""
            print(f"  line {line_number}:{suffix} {line}", file=sys.stderr)

    return 1


def run_self_test() -> int:
    valid = """
// !$*UTF8*$!
{
    objects = {
        0123456789ABCDEF01234567 /* File.swift */ = {isa = PBXFileReference; };
        89ABCDEF0123456701234567 = {isa = PBXGroup; children = (
            0123456789ABCDEF01234567 /* File.swift */,
        ); };
    };
}
"""
    duplicate = """
// !$*UTF8*$!
{
    objects = {
        0123456789ABCDEF01234567 /* File.swift */ = {isa = PBXFileReference; };
        0123456789ABCDEF01234567 /* Script */ = {isa = PBXShellScriptBuildPhase; };
    };
}
"""

    with tempfile.TemporaryDirectory() as directory:
        valid_path = Path(directory) / "valid.pbxproj"
        duplicate_path = Path(directory) / "duplicate.pbxproj"
        valid_path.write_text(valid, encoding="utf-8")
        duplicate_path.write_text(duplicate, encoding="utf-8")

        valid_result = validate(valid_path)
        duplicate_result = validate(duplicate_path)

    if valid_result == 0 and duplicate_result == 1:
        print("OK: self-test passed.")
        return 0

    print("error: self-test failed", file=sys.stderr)
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Detect duplicate PBX object definitions in an Xcode .pbxproj file."
    )
    parser.add_argument("pbxproj", nargs="?", type=Path, help="Path to project.pbxproj")
    parser.add_argument("--self-test", action="store_true", help="Run built-in fixture checks")
    args = parser.parse_args()

    if args.self_test:
        return run_self_test()

    if args.pbxproj is None:
        parser.error("pbxproj is required unless --self-test is used")

    return validate(args.pbxproj)


if __name__ == "__main__":
    raise SystemExit(main())
