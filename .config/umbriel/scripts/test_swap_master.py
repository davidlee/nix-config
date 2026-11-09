"""Tests for swap-master. Run: python3 -m unittest -v"""

import unittest

import fake_umbriel

_path = fake_umbriel.script("swap-master")

# Master layout, one master: a wide master column beside a narrow stack column.
MASTER, STACK = 2000, 600


def tile(x, width, active=False, workspace="DP-3:2", floating=False):
    return {"workspace": workspace, "x": x, "w": width, "floating": floating, "active": active}


def master_left(focus):
    """Master at x=0, a stack of two to its right; `focus` is "master", "stack" or None."""
    return [
        tile(0, MASTER, active=focus == "master"),
        tile(MASTER, STACK, active=focus == "stack"),
        tile(MASTER, STACK),
    ]


def master_right(focus):
    """A stack of two at x=0, master to its right."""
    return [
        tile(0, STACK, active=focus == "stack"),
        tile(0, STACK),
        tile(STACK, MASTER, active=focus == "master"),
    ]


def master_center(focus):
    """A stack each side of a center master; `focus` is "left", "master", "right" or None."""
    return [
        tile(0, STACK, active=focus == "left"),
        tile(STACK, MASTER, active=focus == "master"),
        tile(STACK + MASTER, STACK, active=focus == "right"),
    ]


def press(windows, *args):
    """The `umbriel msg` arguments sent for one press."""
    calls = fake_umbriel.run(_path, windows, *args)
    assert all(call[:2] == ["umbriel", "msg"] for call in calls), calls
    return [call[2:] for call in calls]


class SwapMaster(unittest.TestCase):
    def test_master_on_the_left_swaps_right_into_the_stack(self):
        self.assertEqual(press(master_left("master")), [["window-swap-right"]])

    def test_stack_beside_a_left_master_swaps_left(self):
        self.assertEqual(press(master_left("stack")), [["window-swap-left"]])

    def test_master_on_the_right_swaps_left_into_the_stack(self):
        self.assertEqual(press(master_right("master")), [["window-swap-left"]])

    def test_stack_beside_a_right_master_swaps_right(self):
        self.assertEqual(press(master_right("stack")), [["window-swap-right"]])

    def test_center_master_swaps_left_by_default(self):
        self.assertEqual(press(master_center("master")), [["window-swap-left"]])

    def test_center_master_swaps_toward_the_named_side(self):
        self.assertEqual(press(master_center("master"), "right"), [["window-swap-right"]])
        self.assertEqual(press(master_center("master"), "left"), [["window-swap-left"]])

    def test_center_stacks_swap_with_the_master_whatever_the_side(self):
        for side in ((), ("left",), ("right",)):
            self.assertEqual(press(master_center("left"), *side), [["window-swap-right"]])
            self.assertEqual(press(master_center("right"), *side), [["window-swap-left"]])

    def test_a_side_still_swaps_toward_the_only_other_column(self):
        self.assertEqual(press(master_left("master"), "left"), [["window-swap-right"]])

    def test_a_floating_window_to_the_left_is_not_the_other_column(self):
        windows = [tile(0, 100, floating=True), *[{**w, "x": w["x"] + 100} for w in master_left("master")]]
        self.assertEqual(press(windows), [["window-swap-right"]])

    def test_a_window_on_another_workspace_is_not_the_other_column(self):
        windows = [tile(0, 100, workspace="DP-3:1"), *[{**w, "x": w["x"] + 100} for w in master_left("master")]]
        self.assertEqual(press(windows), [["window-swap-right"]])

    def test_with_nothing_focused_sends_nothing(self):
        self.assertEqual(press(master_left(None)), [])


if __name__ == "__main__":
    unittest.main()
