#!/usr/bin/env python3
"""Capture the debug first-escape Starter Bike payoff screen from an iOS Simulator."""

from __future__ import annotations

import argparse
import plistlib
import subprocess
import time
from pathlib import Path


DEFAULT_BUNDLE_ID = "com.danielwilliams.TrafficGetaway"
DEFAULT_APP_PATH = Path("/tmp/TrafficGetawayVerifyDerivedData/Build/Products/Debug-iphonesimulator/Traffic Getaway.app")
DEFAULT_OUTPUT_DIR = Path("PlaytestArtifacts/progression-payoff")
DEBUG_KEYS = [
    "TrafficGetaway.debug.resultScenario",
    "TrafficGetaway.debug.autoStartLevelID",
    "TrafficGetaway.debug.autoStartVehicleID",
    "TrafficGetaway.debug.autoplay",
    "TrafficGetaway.debug.showOpenLaneAnalysis",
    "TrafficGetaway.debug.waitForStartTap",
]


def run(command: list[str], *, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(command, check=check, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)


def app_container(device: str, bundle_id: str) -> Path:
    return Path(run(["xcrun", "simctl", "get_app_container", device, bundle_id, "data"]).stdout.strip())


def preferences_path(container: Path, bundle_id: str) -> Path:
    return container / "Library" / "Preferences" / f"{bundle_id}.plist"


def read_preferences(path: Path) -> dict:
    if not path.exists():
        return {}
    with path.open("rb") as handle:
        return plistlib.load(handle)


def write_preferences(path: Path, preferences: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as handle:
        plistlib.dump(preferences, handle)


def kill_preferences_cache(device: str) -> None:
    run(["xcrun", "simctl", "spawn", device, "killall", "cfprefsd"], check=False)


def clear_debug_defaults(device: str, container: Path, bundle_id: str) -> None:
    path = preferences_path(container, bundle_id)
    kill_preferences_cache(device)
    preferences = read_preferences(path)
    for key in DEBUG_KEYS:
        preferences.pop(key, None)
    write_preferences(path, preferences)
    kill_preferences_cache(device)
    time.sleep(0.2)
    remaining = [key for key in DEBUG_KEYS if key in read_preferences(path)]
    if remaining:
        run(["xcrun", "simctl", "shutdown", device], check=False)
        preferences = read_preferences(path)
        for key in DEBUG_KEYS:
            preferences.pop(key, None)
        write_preferences(path, preferences)
        run(["xcrun", "simctl", "boot", device], check=False)
        time.sleep(1.0)
        preferences = read_preferences(path)
        for key in DEBUG_KEYS:
            preferences.pop(key, None)
        write_preferences(path, preferences)
        kill_preferences_cache(device)
        time.sleep(0.5)
        remaining = [key for key in DEBUG_KEYS if key in read_preferences(path)]
        if remaining:
            raise RuntimeError(f"Debug defaults still present after cleanup: {', '.join(remaining)}")


def configure_progression_scenario(container: Path, bundle_id: str) -> None:
    path = preferences_path(container, bundle_id)
    preferences = read_preferences(path)
    for key in DEBUG_KEYS:
        preferences.pop(key, None)
    preferences["TrafficGetaway.debug.resultScenario"] = "first_escape_starter_bike"
    write_preferences(path, preferences)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True, help="Simulator UDID")
    parser.add_argument("--bundle-id", default=DEFAULT_BUNDLE_ID)
    parser.add_argument("--app", type=Path, default=DEFAULT_APP_PATH)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--settle-seconds", type=float, default=2.0)
    args = parser.parse_args()

    if not args.app.exists():
        raise SystemExit(f"App bundle not found: {args.app}")

    args.output_dir.mkdir(parents=True, exist_ok=True)
    run(["xcrun", "simctl", "install", args.device, str(args.app)])
    container = app_container(args.device, args.bundle_id)
    configure_progression_scenario(container, args.bundle_id)

    screenshot = args.output_dir / "starter-bike-use-bike-results.png"
    metadata = args.output_dir / "metadata.txt"
    try:
        run(["xcrun", "simctl", "terminate", args.device, args.bundle_id], check=False)
        launch = run(["xcrun", "simctl", "launch", args.device, args.bundle_id])
        time.sleep(args.settle_seconds)
        run(["xcrun", "simctl", "io", args.device, "screenshot", str(screenshot)])
        metadata.write_text(
            "\n".join(
                [
                    "scenario=first_escape_starter_bike",
                    f"device={args.device}",
                    f"bundle_id={args.bundle_id}",
                    f"app={args.app}",
                    f"launch={launch.stdout.strip()}",
                    f"screenshot={screenshot}",
                    "",
                ]
            ),
            encoding="utf-8",
        )
        print(f"captured {screenshot}")
    finally:
        run(["xcrun", "simctl", "terminate", args.device, args.bundle_id], check=False)
        clear_debug_defaults(args.device, container, args.bundle_id)


if __name__ == "__main__":
    main()
