#!/usr/bin/env python3
"""Capture repeated Traffic Getaway live telemetry runs from an iOS Simulator."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path


DEFAULT_BUNDLE_ID = "com.danielwilliams.TrafficGetaway"
DEFAULT_APP_PATH = Path("/tmp/TrafficGetawayVerifyDerivedData/Build/Products/Debug-iphonesimulator/Traffic Getaway.app")
DEFAULT_OUTPUT_DIR = Path("PlaytestArtifacts/live-telemetry")


def run(command: list[str], *, check: bool = True, capture: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(
        command,
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.STDOUT if capture else None,
    )


def simctl(device: str, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    return run(["xcrun", "simctl", *args[:1], device, *args[1:]], check=check)


def app_container(device: str, bundle_id: str) -> Path:
    result = run(["xcrun", "simctl", "get_app_container", device, bundle_id, "data"])
    return Path(result.stdout.strip())


def telemetry_files(container: Path) -> set[Path]:
    telemetry_dir = container / "Documents" / "RunTelemetry"
    if not telemetry_dir.exists():
        return set()
    return set(telemetry_dir.glob("*.jsonl"))


def has_run_ended(path: Path) -> bool:
    try:
        with path.open(encoding="utf-8") as handle:
            return any(json.loads(line).get("event") == "run_ended" for line in handle if line.strip())
    except (OSError, json.JSONDecodeError):
        return False


def newest_completed_run(container: Path, seen: set[Path]) -> Path | None:
    candidates = sorted(telemetry_files(container) - seen, key=lambda path: path.stat().st_mtime, reverse=True)
    for path in candidates:
        if has_run_ended(path):
            return path
    return None


def write_default(device: str, bundle_id: str, key: str, value: str, value_type: str = "-string") -> None:
    simctl(device, "spawn", "defaults", "write", bundle_id, key, value_type, value)


def configure_debug_defaults(device: str, bundle_id: str, level_id: str, vehicle_id: str) -> None:
    write_default(device, bundle_id, "TrafficGetaway.debug.autoStartLevelID", level_id)
    write_default(device, bundle_id, "TrafficGetaway.debug.autoStartVehicleID", vehicle_id)
    write_default(device, bundle_id, "TrafficGetaway.debug.autoplay", "YES", "-bool")
    write_default(device, bundle_id, "TrafficGetaway.debug.showOpenLaneAnalysis", "NO", "-bool")


def clear_debug_defaults(device: str, bundle_id: str) -> None:
    keys = [
        "TrafficGetaway.debug.autoStartLevelID",
        "TrafficGetaway.debug.autoStartVehicleID",
        "TrafficGetaway.debug.autoplay",
        "TrafficGetaway.debug.showOpenLaneAnalysis",
    ]
    for key in keys:
        simctl(device, "spawn", "defaults", "delete", bundle_id, key, check=False)


def capture_runs(args: argparse.Namespace) -> list[Path]:
    if args.app and not args.app.exists():
        raise SystemExit(f"App bundle not found: {args.app}")

    if args.app:
        run(["xcrun", "simctl", "install", args.device, str(args.app)])

    configure_debug_defaults(args.device, args.bundle_id, args.level, args.vehicle)
    container = app_container(args.device, args.bundle_id)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    captured: list[Path] = []
    seen = telemetry_files(container)

    try:
        for run_index in range(1, args.runs + 1):
            simctl(args.device, "terminate", args.bundle_id, check=False)
            launch = simctl(args.device, "launch", args.bundle_id)
            print(launch.stdout.strip(), flush=True)

            deadline = time.time() + args.timeout
            completed: Path | None = None
            while time.time() < deadline:
                completed = newest_completed_run(container, seen)
                if completed:
                    break
                time.sleep(args.poll_interval)

            if not completed:
                raise SystemExit(f"Timed out waiting for run {run_index} to finish after {args.timeout:.0f}s")

            seen.add(completed)
            destination = args.output_dir / f"{run_index:02d}-{completed.name}"
            shutil.copy2(completed, destination)
            captured.append(destination)
            print(f"captured {destination}", flush=True)
    finally:
        simctl(args.device, "terminate", args.bundle_id, check=False)
        if args.clear_defaults:
            clear_debug_defaults(args.device, args.bundle_id)

    return captured


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True, help="Simulator UDID")
    parser.add_argument("--runs", type=int, default=5, help="Number of live runs to capture")
    parser.add_argument("--level", default="la_01", help="Level ID to auto-start")
    parser.add_argument("--vehicle", default="starter_compact", help="Vehicle ID to select before each run")
    parser.add_argument("--bundle-id", default=DEFAULT_BUNDLE_ID)
    parser.add_argument("--app", default=str(DEFAULT_APP_PATH), help="Built .app bundle to install; pass '' to skip")
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--timeout", type=float, default=90)
    parser.add_argument("--poll-interval", type=float, default=1)
    parser.add_argument("--keep-defaults", dest="clear_defaults", action="store_false", help="Leave debug defaults enabled")
    parser.set_defaults(clear_defaults=True)
    args = parser.parse_args()

    if args.runs < 1:
        raise SystemExit("--runs must be at least 1")
    if args.app == "":
        args.app = None
    else:
        args.app = Path(args.app)

    captured = capture_runs(args)
    print("")
    print("Captured telemetry files:")
    for path in captured:
        print(path)
    print("")
    print("Summarize with:")
    print(f"python3 scripts/summarize_run_telemetry.py {args.output_dir}")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        output = error.stdout or ""
        sys.stderr.write(output)
        raise SystemExit(error.returncode) from error
