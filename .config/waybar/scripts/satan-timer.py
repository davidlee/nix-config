#!/usr/bin/env python3
"""Waybar SATAN countdown timer.

Subcommands:
  display    waybar JSON (called every interval)
  toggle     pause/resume (right click)
  incr       +10m to duration and remaining (scroll up)
  decr       -10m, floor 60s (scroll down)
  set        zenity prompt for new duration in minutes (middle click)

State at $XDG_RUNTIME_DIR/satan-timer.json (volatile across reboot).
Running:  {"duration": N, "deadline": float_epoch}
Paused:   {"duration": N, "remaining": float_seconds}

On expiry: notify-send + ~/.emacs.d/satan/bin/satan-run-tick, then re-arm
deadline = now + duration. Periodic, not one-shot. After a long gap (e.g.
laptop suspended past a full cycle) realigns without firing a burst.
"""
import json
import os
import subprocess
import sys
import time
from pathlib import Path

STATE = (Path(os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}")
         / "satan-timer.json")
DEFAULT_DURATION = 30 * 60
INCR_STEP = 10 * 60
MIN_DURATION = 60
SATAN_TICK = Path.home() / ".emacs.d/satan/bin/satan-run-tick"
ZENITY_VALUES = "5|10|15|20|25|30|45|60|90|120"


def load() -> dict:
    try:
        data = json.loads(STATE.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return {"duration": DEFAULT_DURATION,
                "deadline": time.time() + DEFAULT_DURATION}
    data.setdefault("duration", DEFAULT_DURATION)
    return data


def save(d: dict) -> None:
    STATE.parent.mkdir(parents=True, exist_ok=True)
    tmp = STATE.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(d))
    tmp.replace(STATE)


def fire() -> None:
    subprocess.Popen(["notify-send", "-u", "low", "Satan is coming"])
    if SATAN_TICK.exists():
        subprocess.Popen([str(SATAN_TICK)])


def cmd_display() -> None:
    d = load()
    now = time.time()
    paused = "remaining" in d
    if paused:
        remaining = d["remaining"]
    else:
        remaining = d["deadline"] - now
        if remaining < -d["duration"]:
            d["deadline"] = now + d["duration"]
            remaining = d["duration"]
            save(d)
        elif remaining <= 0:
            while remaining <= 0:
                fire()
                d["deadline"] += d["duration"]
                remaining = d["deadline"] - now
            save(d)
    total = max(0, int(remaining + 0.5))
    mm, ss = divmod(total, 60)
    icon = "⏸ " if paused else "👹 " #"⛧ "
    cls = "paused" if paused else ("warn" if total <= 60 else "running")
    print(json.dumps({
        "text": f"{icon}{mm:02d}:{ss:02d}",
        "class": cls,
        "tooltip": (f"SATAN timer · {d['duration'] // 60}m cycle\n"
                    f"Left-click: pause/resume\n"
                    f"Right-click: pause/resume\n"
                    f"Scroll: ±10m\n"
                    f"Middle: set duration"),
    }))


def cmd_toggle() -> None:
    d = load()
    now = time.time()
    if "remaining" in d:
        d["deadline"] = now + d["remaining"]
        del d["remaining"]
    else:
        d["remaining"] = max(0.0, d["deadline"] - now)
    save(d)


def adjust(delta: int) -> None:
    d = load()
    new_duration = max(MIN_DURATION, d["duration"] + delta)
    diff = new_duration - d["duration"]
    d["duration"] = new_duration
    if "remaining" in d:
        d["remaining"] = max(0.0, d["remaining"] + diff)
    else:
        d["deadline"] += diff
    save(d)


def cmd_set() -> None:
    try:
        r = subprocess.run(
            ["zenity", "--forms",
             "--add-list", "minutes",
             "--list-values", ZENITY_VALUES,
             "--text", "How long?",
             "--timeout", "30",
             "--title", "SATAN timer"],
            capture_output=True, text=True, timeout=35,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return
    if r.returncode != 0:
        return
    try:
        minutes = int(r.stdout.strip())
    except ValueError:
        return
    new_duration = max(MIN_DURATION, minutes * 60)
    d = load()
    d["duration"] = new_duration
    if "remaining" in d:
        d["remaining"] = float(new_duration)
    else:
        d["deadline"] = time.time() + new_duration
    save(d)


CMDS = {
    "display": cmd_display,
    "toggle": cmd_toggle,
    "incr": lambda: adjust(INCR_STEP),
    "decr": lambda: adjust(-INCR_STEP),
    "set": cmd_set,
}

if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in CMDS:
        sys.stderr.write(f"usage: satan-timer.py [{'|'.join(CMDS)}]\n")
        sys.exit(2)
    CMDS[sys.argv[1]]()
