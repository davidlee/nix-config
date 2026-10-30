"""Tests for raise-cycle-or-spawn. Run: python3 -m unittest -v"""

import importlib.machinery
import importlib.util
import json
import os
import pathlib
import subprocess
import sys
import tempfile
import unittest

_path = str(pathlib.Path(__file__).with_name("raise-cycle-or-spawn"))
_loader = importlib.machinery.SourceFileLoader("raise_cycle_or_spawn", _path)
_spec = importlib.util.spec_from_loader(_loader.name, _loader)
rcs = importlib.util.module_from_spec(_spec)
_loader.exec_module(rcs)


def press(windows, active, cycle, now):
    """Run one press, then apply umbriel's MRU promotion of the focused window."""
    target, cycle = rcs.choose(windows, active, cycle, now)
    return target, [target] + [w for w in windows if w != target], cycle


def presses(windows, active, count, gap=0.1):
    """Focus ids from `count` presses `gap` seconds apart, starting from `active`."""
    focused, cycle = [], None
    for n in range(count):
        active, windows, cycle = press(windows, active, cycle, n * gap)
        focused.append(active)
    return focused


class Choose(unittest.TestCase):
    def test_from_another_app_focuses_most_recent(self):
        self.assertEqual(presses(["a", "b", "c"], "other", 1), ["a"])

    def test_repeated_presses_walk_most_to_least_recent_then_wrap(self):
        self.assertEqual(presses(["a", "b", "c", "d"], "a", 5), ["b", "c", "d", "a", "b"])

    def test_single_window_stays_focused(self):
        self.assertEqual(presses(["a"], "a", 2), ["a", "a"])

    def test_pause_starts_a_new_run_from_current_order(self):
        self.assertEqual(presses(["a", "b", "c"], "a", 3, gap=rcs.CYCLE_TIMEOUT + 1), ["b", "a", "b"])

    def test_focus_moved_elsewhere_starts_a_new_run(self):
        _, windows, cycle = press(["a", "b", "c"], "a", None, 0)
        windows = ["c"] + [w for w in windows if w != "c"]
        self.assertEqual(rcs.choose(windows, "c", cycle, 0.1)[0], "b")

    def test_closed_window_is_skipped(self):
        _, windows, cycle = press(["a", "b", "c", "d"], "a", None, 0)
        windows.remove("c")
        self.assertEqual(rcs.choose(windows, "b", cycle, 0.1)[0], "d")


# Stands in for `umbriel` and for the launched app: serves `umbriel windows`,
# records every other invocation's argv as one JSON line.
_FAKE = f"""#!{sys.executable}
import json, os, pathlib, sys
fake = pathlib.Path(os.environ["FAKE_DIR"])
argv = [pathlib.Path(sys.argv[0]).name, *sys.argv[1:]]
if argv[:2] == ["umbriel", "windows"]:
    sys.stdout.write((fake / "windows.json").read_text())
else:
    with (fake / "calls").open("a") as f:
        f.write(json.dumps(argv) + "\\n")
"""


def window(id, app_id, active=False):
    return {"id": id, "app_id": app_id, "active": active}


def run(windows, *args):
    """Run the script against a fake umbriel; return the argv of each command it ran."""
    with tempfile.TemporaryDirectory() as tmp:
        fake = pathlib.Path(tmp)
        for name in ("umbriel", "fake-app"):
            (fake / name).write_text(_FAKE)
            (fake / name).chmod(0o755)
        (fake / "windows.json").write_text(json.dumps(windows))
        env = {**os.environ, "FAKE_DIR": tmp, "XDG_RUNTIME_DIR": tmp, "PATH": f"{tmp}:{os.environ['PATH']}"}
        subprocess.run([_path, *args], env=env, check=True)
        calls = fake / "calls"
        return [json.loads(line) for line in calls.read_text().splitlines()] if calls.exists() else []


class Main(unittest.TestCase):
    def test_focuses_the_match_with_action_and_id_as_separate_words(self):
        windows = [window("t1", "term", active=True), window("e1", "editor")]
        self.assertEqual(run(windows, "editor", "fake-app"), [["umbriel", "msg", "window-focus", "e1"]])

    def test_launches_the_command_when_nothing_matches(self):
        windows = [window("t1", "term", active=True)]
        self.assertEqual(run(windows, "editor", "fake-app", "-n", "two words"), [["fake-app", "-n", "two words"]])


if __name__ == "__main__":
    unittest.main()
