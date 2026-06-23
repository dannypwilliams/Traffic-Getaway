#!/usr/bin/env python3
"""Validate telemetry from a USE BIKE tap-through smoke run."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def read_events(path: Path) -> list[dict]:
    events: list[dict] = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                events.append(json.loads(line))
    return events


def validate(path: Path) -> dict:
    events = read_events(path)
    run_started = next((event for event in events if event.get("event") == "run_started"), None)
    if run_started is None:
        raise SystemExit("FAIL: telemetry did not include run_started")

    expected = {
        "levelID": "la_02",
        "vehicleID": "starter_bike",
        "vehicleClass": "motorcycle",
    }
    mismatches = [
        f"{key}={run_started.get(key)!r}"
        for key, expected_value in expected.items()
        if run_started.get(key) != expected_value
    ]
    if mismatches:
        raise SystemExit("FAIL: unexpected run_started telemetry: " + ", ".join(mismatches))

    lane_changes = [event for event in events if event.get("event") == "lane_changed"]
    split_lane_changes = [
        event for event in lane_changes
        if event.get("vehicleClass") == "motorcycle" and event.get("playerSlot") % 2 == 1
    ]
    if not split_lane_changes:
        raise SystemExit("FAIL: no motorcycle lane change into an interstitial split slot was recorded")

    return {
        "events": len(events),
        "runStarted": {
            "levelID": run_started.get("levelID"),
            "vehicleID": run_started.get("vehicleID"),
            "vehicleClass": run_started.get("vehicleClass"),
            "playerSlot": run_started.get("playerSlot"),
        },
        "laneChangedEvents": len(lane_changes),
        "splitSlotLaneChangedEvents": len(split_lane_changes),
        "firstSplitSlotEvent": {
            "time": split_lane_changes[0].get("time"),
            "playerSlot": split_lane_changes[0].get("playerSlot"),
            "playerLane": split_lane_changes[0].get("playerLane"),
            "distance": split_lane_changes[0].get("distance"),
            "score": split_lane_changes[0].get("score"),
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("telemetry", type=Path)
    args = parser.parse_args()
    result = validate(args.telemetry)
    print("PASS: USE BIKE tap-through telemetry validated")
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
