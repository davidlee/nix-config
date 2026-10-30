"""Tests for raise-cycle-or-spawn. Run: python3 -m unittest -v"""

import importlib.machinery
import importlib.util
import pathlib
import unittest

import fake_umbriel

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


def window(id, app_id, active=False):
    return {"id": id, "app_id": app_id, "active": active}


def run(windows, *args):
    return fake_umbriel.run(_path, windows, *args)


class Main(unittest.TestCase):
    def test_focuses_the_match_with_action_and_id_as_separate_words(self):
        windows = [window("t1", "term", active=True), window("e1", "editor")]
        self.assertEqual(run(windows, "editor", "fake-app"), [["umbriel", "msg", "window-focus", "e1"]])

    def test_launches_the_command_when_nothing_matches(self):
        windows = [window("t1", "term", active=True)]
        self.assertEqual(run(windows, "editor", "fake-app", "-n", "two words"), [["fake-app", "-n", "two words"]])


if __name__ == "__main__":
    unittest.main()
