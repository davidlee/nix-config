#!/usr/bin/env python3
"""Waybar WPM daemon + archival.

Daemon (--daemon):
  Watches every keyboard via evdev, writes a JSON snapshot to
  $XDG_RUNTIME_DIR/wpm.json once per second, and appends one
  per-minute aggregate row to ~/notes/satan/log/wpm/YYYY-MM-DD.tsv.

  TSV columns: <iso8601_local> <keys> <peak_5s_wpm> <active_seconds>

  Counts EV_KEY value==1 (press) only, every key including modifiers —
  matches the bash version's behaviour. Heavy modifier use inflates the
  figure ~20-30%; revisit if a "real characters" metric is wanted later.

  Waybar reads the snapshot directly with `cat`; no Python startup per tick.

Archival (--archive-hourly FILE):
  Re-aggregates a per-minute TSV into hourly rows, replacing the file
  atomically.

  TSV columns: <iso8601_hour> <keys> <peak_5s_wpm> <active_seconds> <active_minutes>
"""
import json
import os
import selectors
import sys
import time
from collections import deque
from datetime import datetime
from pathlib import Path

import evdev

INSTANT_WIN = 5
STABLE_WIN = 60
RESCAN_S = 30
SNAP_S = 1
MINUTE_S = 60

RUNTIME = Path(os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}")
SNAP = RUNTIME / "wpm.json"
SNAP_TMP = RUNTIME / "wpm.json.tmp"
LOG_DIR = Path.home() / "notes/satan/log/wpm"


def log(msg: str) -> None:
    print(msg, file=sys.stderr, flush=True)


def is_keyboard(dev: evdev.InputDevice) -> bool:
    keys = dev.capabilities().get(evdev.ecodes.EV_KEY, [])
    return evdev.ecodes.KEY_A in keys


def discover() -> dict[str, evdev.InputDevice]:
    out: dict[str, evdev.InputDevice] = {}
    for path in evdev.list_devices():
        try:
            d = evdev.InputDevice(path)
        except (OSError, PermissionError) as e:
            log(f"skip {path}: {e}")
            continue
        if is_keyboard(d):
            out[path] = d
        else:
            d.close()
    return out


def sync(devs: dict[str, evdev.InputDevice],
         sel: selectors.BaseSelector,
         registered: set[int]) -> None:
    wanted = {d.fd for d in devs.values()}
    for fd in list(registered):
        if fd not in wanted:
            try:
                sel.unregister(fd)
            except KeyError:
                pass
            registered.discard(fd)
    for d in devs.values():
        if d.fd not in registered:
            sel.register(d.fd, selectors.EVENT_READ, d)
            registered.add(d.fd)


def write_snapshot(stamps: deque, dev_count: int, last_min_keys: int) -> None:
    now = time.monotonic()
    instant = sum(1 for t in stamps if t > now - INSTANT_WIN)
    stable = sum(1 for t in stamps if t > now - STABLE_WIN)
    wpm_instant = round(instant * 12 / INSTANT_WIN)
    wpm_stable = round(stable / 5)
    obj = {
        "text": f"⌨ {wpm_instant}",
        "tooltip": (f"60s avg: {wpm_stable} WPM\n"
                    f"Last min keys: {last_min_keys}\n"
                    f"Devices: {dev_count}"),
    }
    if wpm_instant > 100:
        obj["class"] = "fast"
    SNAP_TMP.write_text(json.dumps(obj))
    SNAP_TMP.replace(SNAP)


def append_minute(buckets: dict[int, int], minute_start: int) -> int:
    total = sum(buckets.values())
    if total == 0:
        return 0
    peak_window = 0
    for s in buckets:
        w = sum(v for k, v in buckets.items() if s <= k < s + INSTANT_WIN)
        if w > peak_window:
            peak_window = w
    peak_wpm = round(peak_window * 12 / INSTANT_WIN)
    active = len(buckets)
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.fromtimestamp(minute_start)
    path = LOG_DIR / f"{stamp.strftime('%Y-%m-%d')}.tsv"
    with path.open("a") as f:
        f.write(f"{stamp.isoformat(timespec='seconds')}\t{total}\t{peak_wpm}\t{active}\n")
    return total


def main() -> None:
    sel = selectors.DefaultSelector()
    devs = discover()
    registered: set[int] = set()
    sync(devs, sel, registered)
    log(f"watching {len(devs)} keyboards: {[d.name for d in devs.values()]}")

    stamps: deque[float] = deque()
    keys_per_sec: dict[int, int] = {}
    last_snap = 0.0
    last_minute = int(time.time()) // MINUTE_S
    last_rescan = time.monotonic()
    last_min_keys = 0

    while True:
        events = sel.select(timeout=SNAP_S)
        mono = time.monotonic()
        for key, _ in events:
            d: evdev.InputDevice = key.data
            try:
                for ev in d.read():
                    if ev.type == evdev.ecodes.EV_KEY and ev.value == 1:
                        stamps.append(mono)
                        sec = int(time.time())
                        keys_per_sec[sec] = keys_per_sec.get(sec, 0) + 1
            except BlockingIOError:
                pass
            except OSError as e:
                log(f"device {d.path} gone ({e}); rescanning")
                path = d.path
                try:
                    sel.unregister(d.fd)
                except KeyError:
                    pass
                registered.discard(d.fd)
                devs.pop(path, None)
                try:
                    d.close()
                except Exception:
                    pass
                devs.update({p: nd for p, nd in discover().items() if p not in devs})
                sync(devs, sel, registered)
                last_rescan = mono

        cutoff = mono - STABLE_WIN
        while stamps and stamps[0] < cutoff:
            stamps.popleft()

        if mono - last_rescan > RESCAN_S:
            before = set(devs)
            devs.update({p: nd for p, nd in discover().items() if p not in devs})
            new = set(devs) - before
            if new:
                log(f"hotplug: added {sorted(new)}")
            sync(devs, sel, registered)
            last_rescan = mono

        if mono - last_snap >= SNAP_S:
            write_snapshot(stamps, len(devs), last_min_keys)
            last_snap = mono

        now_min = int(time.time()) // MINUTE_S
        if now_min != last_minute:
            minute_start = last_minute * MINUTE_S
            minute_end = now_min * MINUTE_S
            buckets = {k: v for k, v in keys_per_sec.items()
                       if minute_start <= k < minute_end}
            last_min_keys = append_minute(buckets, minute_start)
            keys_per_sec = {k: v for k, v in keys_per_sec.items() if k >= minute_end}
            last_minute = now_min


def archive_hourly(path: Path) -> None:
    buckets: dict[datetime, list[int]] = {}
    first_cols: int | None = None
    with path.open() as f:
        for lineno, raw in enumerate(f, 1):
            line = raw.rstrip("\n")
            if not line:
                continue
            cols = line.split("\t")
            if first_cols is None:
                first_cols = len(cols)
                if first_cols == 5:
                    log(f"{path}: already hourly (5 cols); skipping")
                    return
            if len(cols) != 4:
                raise SystemExit(
                    f"{path}:{lineno}: expected 4 columns (per-minute), got {len(cols)}"
                )
            ts_s, keys_s, peak_s, active_s = cols
            ts = datetime.fromisoformat(ts_s)
            hour = ts.replace(minute=0, second=0, microsecond=0)
            b = buckets.setdefault(hour, [0, 0, 0, 0])
            b[0] += int(keys_s)
            b[1] = max(b[1], int(peak_s))
            b[2] += int(active_s)
            b[3] += 1
    if not buckets:
        return
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w") as f:
        for hour in sorted(buckets):
            keys, peak, active_sec, active_min = buckets[hour]
            f.write(
                f"{hour.isoformat(timespec='seconds')}\t"
                f"{keys}\t{peak}\t{active_sec}\t{active_min}\n"
            )
    tmp.replace(path)


USAGE = (
    "usage: wpm-status.py --daemon\n"
    "       wpm-status.py --archive-hourly FILE\n"
)

if __name__ == "__main__":
    argv = sys.argv[1:]
    if argv == ["--daemon"]:
        main()
    elif len(argv) == 2 and argv[0] == "--archive-hourly":
        archive_hourly(Path(argv[1]))
    else:
        sys.stderr.write(USAGE)
        sys.exit(2)
