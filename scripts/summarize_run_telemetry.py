#!/usr/bin/env python3
"""Summarize Traffic Getaway JSONL run telemetry."""

from __future__ import annotations

import argparse
import glob
import json
import statistics
from collections import Counter
from pathlib import Path
from typing import Iterable


def expand_inputs(inputs: Iterable[str]) -> list[Path]:
    paths: list[Path] = []
    for value in inputs:
        matches = glob.glob(value)
        candidates = matches if matches else [value]
        for candidate in candidates:
            path = Path(candidate)
            if path.is_dir():
                paths.extend(sorted(path.rglob("*.jsonl")))
            elif path.suffix == ".jsonl":
                paths.append(path)
    return sorted(dict.fromkeys(paths))


def load_events(path: Path) -> list[dict]:
    events: list[dict] = []
    with path.open(encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError as error:
                raise SystemExit(f"{path}:{line_number}: invalid JSON: {error}") from error
    return events


def median(values: list[float]) -> float:
    if not values:
        return 0.0
    return float(statistics.median(values))


def average(values: list[float]) -> float:
    if not values:
        return 0.0
    return float(sum(values) / len(values))


def fmt_float(value: float, digits: int = 1) -> str:
    return f"{value:.{digits}f}"


def summarize_run(path: Path, events: list[dict]) -> dict:
    starts = [event for event in events if event.get("event") == "run_started"]
    ends = [event for event in events if event.get("event") == "run_ended"]
    collisions = [event for event in events if event.get("event") == "collision"]
    waves = [event for event in events if event.get("event") == "traffic_wave"]
    decisions = [event.get("movementDecision") for event in events if event.get("movementDecision")]
    move_decisions = [decision for decision in decisions if decision.get("status") == "move"]
    target_mismatches = [
        decision for decision in decisions
        if decision.get("targetSlot") is not None
        and decision.get("simPolicyTargetSlot") is not None
        and decision.get("targetSlot") != decision.get("simPolicyTargetSlot")
    ]
    move_target_mismatches = [
        decision for decision in move_decisions
        if decision.get("targetSlot") != decision.get("simPolicyTargetSlot")
    ]
    applied_mismatches = [
        decision for decision in move_decisions
        if decision.get("appliedSlot") != decision.get("simPolicyTargetSlot")
    ]
    terminal = ends[-1] if ends else (collisions[-1] if collisions else (events[-1] if events else {}))
    first = starts[0] if starts else (events[0] if events else {})
    pattern_counts = Counter(event.get("patternID") for event in waves if event.get("patternID"))
    terminal_reason = terminal.get("terminalReason") or ("open" if events else "empty")
    completed = bool(terminal.get("levelCompleted"))
    terminal_time = float(terminal.get("time") or 0)
    first_crash_time = float(collisions[0].get("time") or 0) if collisions else 0.0

    return {
        "path": path,
        "events": len(events),
        "level": first.get("levelID") or terminal.get("levelID") or "",
        "vehicle": first.get("vehicleID") or terminal.get("vehicleID") or "",
        "seed": first.get("seed") or terminal.get("seed") or "",
        "terminal_reason": terminal_reason,
        "completed": completed,
        "terminal_time": terminal_time,
        "first_crash_time": first_crash_time,
        "waves": len(waves),
        "near_misses": int(terminal.get("nearMisses") or 0),
        "lane_splits": int(terminal.get("laneSplits") or 0),
        "distance": int(terminal.get("distance") or 0),
        "score": int(terminal.get("score") or 0),
        "cash": int(terminal.get("cash") or 0),
        "wanted_level": int(terminal.get("wantedLevel") or 0),
        "pattern_counts": pattern_counts,
        "has_collision_rects": bool(
            terminal.get("collisionPlayerRect")
            or terminal.get("collisionTrafficRect")
            or any(event.get("collisionPlayerRect") for event in collisions)
        ),
        "has_active_traffic": any(event.get("activeTraffic") for event in events),
        "autoplay_decisions": len(decisions),
        "autoplay_moves": len(move_decisions),
        "target_mismatches": len(target_mismatches),
        "move_target_mismatches": len(move_target_mismatches),
        "applied_mismatches": len(applied_mismatches),
    }


def print_markdown(summaries: list[dict]) -> None:
    print("# Run Telemetry Summary")
    print()
    if not summaries:
        print("No JSONL telemetry files found.")
        return

    completed = sum(1 for item in summaries if item["completed"])
    crash_times = [item["first_crash_time"] for item in summaries if item["first_crash_time"] > 0]
    terminal_times = [item["terminal_time"] for item in summaries if item["terminal_time"] > 0]
    pattern_counts: Counter = Counter()
    terminal_counts: Counter = Counter()
    for item in summaries:
        pattern_counts.update(item["pattern_counts"])
        terminal_counts[item["terminal_reason"]] += 1

    print(f"- Runs: {len(summaries)}")
    print(f"- Completed: {completed}/{len(summaries)} ({completed / len(summaries) * 100:.1f}%)")
    print(f"- Avg terminal time: {fmt_float(average(terminal_times))}s")
    print(f"- Median terminal time: {fmt_float(median(terminal_times))}s")
    if crash_times:
        print(f"- Avg first crash: {fmt_float(average(crash_times))}s")
        print(f"- Median first crash: {fmt_float(median(crash_times))}s")
    print(f"- Avg traffic waves: {fmt_float(average([item['waves'] for item in summaries]))}")
    print(f"- Avg near misses: {fmt_float(average([item['near_misses'] for item in summaries]))}")
    print(f"- Avg cash: {fmt_float(average([item['cash'] for item in summaries]), 0)}")
    print(f"- Autoplay decisions: {sum(item['autoplay_decisions'] for item in summaries)}")
    print(f"- Autoplay move decisions: {sum(item['autoplay_moves'] for item in summaries)}")
    print(f"- Autoplay target mismatches: {sum(item['target_mismatches'] for item in summaries)}")
    print(f"- Autoplay move-target mismatches: {sum(item['move_target_mismatches'] for item in summaries)}")
    print(f"- Autoplay applied-slot mismatches: {sum(item['applied_mismatches'] for item in summaries)}")
    print(f"- Terminal reasons: {dict(sorted(terminal_counts.items()))}")
    print(f"- Pattern mix: {dict(sorted(pattern_counts.items()))}")
    print()
    print("| File | Level | Vehicle | Seed | Terminal | Completed | Time | Waves | Near misses | Cash | Wanted | Collision rects | Active traffic | Decisions | Target mismatch | Applied mismatch |")
    print("|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---|---|---:|---:|---:|")
    for item in summaries:
        print(
            "| "
            f"{item['path'].name} | "
            f"{item['level']} | "
            f"{item['vehicle']} | "
            f"{item['seed']} | "
            f"{item['terminal_reason']} | "
            f"{str(item['completed']).lower()} | "
            f"{fmt_float(item['terminal_time'])} | "
            f"{item['waves']} | "
            f"{item['near_misses']} | "
            f"{item['cash']} | "
            f"{item['wanted_level']} | "
            f"{str(item['has_collision_rects']).lower()} |"
            f" {str(item['has_active_traffic']).lower()} | "
            f"{item['autoplay_decisions']} | "
            f"{item['target_mismatches']} | "
            f"{item['applied_mismatches']} |"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="+", help="JSONL files, directories, or globs")
    args = parser.parse_args()

    summaries = [summarize_run(path, load_events(path)) for path in expand_inputs(args.paths)]
    print_markdown(summaries)


if __name__ == "__main__":
    main()
