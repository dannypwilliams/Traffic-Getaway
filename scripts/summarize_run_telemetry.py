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
    lane_changes = [event for event in events if event.get("event") == "lane_changed"]
    decisions = [event.get("movementDecision") for event in events if event.get("movementDecision")]
    lane_probes = [event.get("laneChangeProbe") for event in events if event.get("laneChangeProbe")]
    move_decisions = [decision for decision in decisions if decision.get("status") == "move"]
    decision_sources = Counter(decision.get("source", "missing") for decision in decisions)
    decision_statuses = Counter(decision.get("status", "missing") for decision in decisions)
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
    collision_analyses = [event.get("collisionAnalysis") for event in collisions if event.get("collisionAnalysis")]
    first_collision_analysis = collision_analyses[0] if collision_analyses else {}
    last_collision_decision = first_collision_analysis.get("lastMovementDecision") or {}
    collision_overlap_area = float(first_collision_analysis.get("overlapArea") or 0)
    collision_active_traffic_count = len(first_collision_analysis.get("activeTraffic") or [])
    lane_probe_transitions = {probe.get("transitionID") for probe in lane_probes if probe.get("transitionID") is not None}
    lane_probe_intersections = [probe for probe in lane_probes if probe.get("intersectsTraffic")]
    lane_probe_unsafe = [probe for probe in lane_probes if probe.get("pathUnsafeSlots")]
    lane_probe_path_dangers = [float(probe.get("pathMaxDanger") or 0) for probe in lane_probes]
    collision_time = float(collisions[0].get("time") or 0) if collisions else None
    probes_before_collision = [
        event.get("laneChangeProbe")
        for event in events
        if event.get("laneChangeProbe") and collision_time is not None and float(event.get("time") or 0) <= collision_time
    ]
    last_probe_before_collision = probes_before_collision[-1] if probes_before_collision else {}

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
        "lane_changes": len(lane_changes),
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
        "has_collision_analysis": bool(collision_analyses),
        "collision_overlap_area": collision_overlap_area,
        "collision_active_traffic_count": collision_active_traffic_count,
        "collision_last_decision_source": last_collision_decision.get("source", ""),
        "collision_last_decision_status": last_collision_decision.get("status", ""),
        "collision_last_decision_age": first_collision_analysis.get("lastMovementDecisionAge"),
        "lane_change_probes": len(lane_probes),
        "lane_change_transitions": len(lane_probe_transitions),
        "lane_change_intersection_probes": len(lane_probe_intersections),
        "lane_change_unsafe_probes": len(lane_probe_unsafe),
        "lane_change_max_path_danger": max(lane_probe_path_dangers) if lane_probe_path_dangers else 0.0,
        "last_probe_intersects": bool(last_probe_before_collision.get("intersectsTraffic")),
        "last_probe_progress": last_probe_before_collision.get("progress"),
        "last_probe_path_danger": last_probe_before_collision.get("pathMaxDanger"),
        "autoplay_decisions": len(decisions),
        "autoplay_moves": len(move_decisions),
        "autoplay_sources": decision_sources,
        "autoplay_statuses": decision_statuses,
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
    source_counts: Counter = Counter()
    status_counts: Counter = Counter()
    collision_source_counts: Counter = Counter()
    collision_status_counts: Counter = Counter()
    last_probe_intersections = 0
    for item in summaries:
        pattern_counts.update(item["pattern_counts"])
        terminal_counts[item["terminal_reason"]] += 1
        source_counts.update(item["autoplay_sources"])
        status_counts.update(item["autoplay_statuses"])
        if item["collision_last_decision_source"]:
            collision_source_counts[item["collision_last_decision_source"]] += 1
        if item["collision_last_decision_status"]:
            collision_status_counts[item["collision_last_decision_status"]] += 1
        if item["last_probe_intersects"]:
            last_probe_intersections += 1

    print(f"- Runs: {len(summaries)}")
    print(f"- Completed: {completed}/{len(summaries)} ({completed / len(summaries) * 100:.1f}%)")
    print(f"- Avg terminal time: {fmt_float(average(terminal_times))}s")
    print(f"- Median terminal time: {fmt_float(median(terminal_times))}s")
    if crash_times:
        print(f"- Avg first crash: {fmt_float(average(crash_times))}s")
        print(f"- Median first crash: {fmt_float(median(crash_times))}s")
    print(f"- Avg traffic waves: {fmt_float(average([item['waves'] for item in summaries]))}")
    print(f"- Avg near misses: {fmt_float(average([item['near_misses'] for item in summaries]))}")
    print(f"- Active-input runs: {sum(1 for item in summaries if item['lane_changes'] > 0)}/{len(summaries)}")
    print(f"- Lane changed events: {sum(item['lane_changes'] for item in summaries)}")
    print(f"- Avg cash: {fmt_float(average([item['cash'] for item in summaries]), 0)}")
    print(f"- Autoplay decisions: {sum(item['autoplay_decisions'] for item in summaries)}")
    print(f"- Autoplay move decisions: {sum(item['autoplay_moves'] for item in summaries)}")
    print(f"- Autoplay target mismatches: {sum(item['target_mismatches'] for item in summaries)}")
    print(f"- Autoplay move-target mismatches: {sum(item['move_target_mismatches'] for item in summaries)}")
    print(f"- Autoplay applied-slot mismatches: {sum(item['applied_mismatches'] for item in summaries)}")
    print(f"- Collision analyses: {sum(1 for item in summaries if item['has_collision_analysis'])}/{len(summaries)}")
    print(f"- Avg collision overlap area: {fmt_float(average([item['collision_overlap_area'] for item in summaries]))}")
    print(f"- Avg active traffic at collision: {fmt_float(average([item['collision_active_traffic_count'] for item in summaries]))}")
    print(f"- Lane-change probes: {sum(item['lane_change_probes'] for item in summaries)}")
    print(f"- Lane-change transitions: {sum(item['lane_change_transitions'] for item in summaries)}")
    print(f"- Lane-change intersection probes: {sum(item['lane_change_intersection_probes'] for item in summaries)}")
    print(f"- Lane-change unsafe-path probes: {sum(item['lane_change_unsafe_probes'] for item in summaries)}")
    print(f"- Max lane-change path danger: {fmt_float(max(item['lane_change_max_path_danger'] for item in summaries))}")
    print(f"- Last pre-crash probe intersected traffic: {last_probe_intersections}/{len(summaries)}")
    if collision_source_counts:
        print(f"- Collision last-decision sources: {dict(sorted(collision_source_counts.items()))}")
    if collision_status_counts:
        print(f"- Collision last-decision statuses: {dict(sorted(collision_status_counts.items()))}")
    if source_counts:
        print(f"- Autoplay decision sources: {dict(sorted(source_counts.items()))}")
    if status_counts:
        print(f"- Autoplay decision statuses: {dict(sorted(status_counts.items()))}")
    print(f"- Terminal reasons: {dict(sorted(terminal_counts.items()))}")
    print(f"- Pattern mix: {dict(sorted(pattern_counts.items()))}")
    print()
    print("| File | Level | Vehicle | Seed | Terminal | Completed | Time | Waves | Near misses | Lane changes | Cash | Wanted | Collision rects | Collision analysis | Active traffic | Lane probes | Probe intersections | Decisions | Target mismatch | Applied mismatch |")
    print("|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---|---|---|---:|---:|---:|---:|---:|")
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
            f"{item['lane_changes']} | "
            f"{item['cash']} | "
            f"{item['wanted_level']} | "
            f"{str(item['has_collision_rects']).lower()} |"
            f" {str(item['has_collision_analysis']).lower()} |"
            f" {str(item['has_active_traffic']).lower()} | "
            f"{item['lane_change_probes']} | "
            f"{item['lane_change_intersection_probes']} | "
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
