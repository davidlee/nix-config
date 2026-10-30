"""Tests for focus-vertical. Run: python3 -m unittest -v"""

import unittest

import fake_umbriel

_path = fake_umbriel.script("focus-vertical")


def tile(column, row, active=False, tab_index=-1):
    return {
        "workspace": "DP-3:1",
        "column": column,
        "row": row,
        "floating": False,
        "tabbed": tab_index >= 0,
        "tab_index": tab_index,
        "active": active,
    }


def press(windows, direction):
    """The `umbriel msg` arguments sent for one press."""
    calls = fake_umbriel.run(_path, windows, direction)
    assert all(call[:2] == ["umbriel", "msg"] for call in calls), calls
    return [call[2:] for call in calls]


class FocusVertical(unittest.TestCase):
    def test_down_inside_a_group_steps_to_the_next_tab(self):
        group = [tile(1, 0, active=True, tab_index=0), tile(1, 1, tab_index=1)]
        self.assertEqual(press(group, "down"), [["column-focus-tab-next"]])

    def test_up_inside_a_group_steps_to_the_previous_tab(self):
        group = [tile(1, 0, tab_index=0), tile(1, 1, active=True, tab_index=1)]
        self.assertEqual(press(group, "up"), [["column-focus-tab-previous"]])

    def test_down_from_the_last_tab_leaves_the_group(self):
        windows = [tile(1, 0, tab_index=0), tile(1, 1, active=True, tab_index=1), tile(1, 2)]
        self.assertEqual(press(windows, "down"), [["window-focus-down"]])

    def test_up_from_the_first_tab_leaves_the_group(self):
        windows = [tile(1, 0), tile(1, 1, active=True, tab_index=0), tile(1, 2, tab_index=1)]
        self.assertEqual(press(windows, "up"), [["window-focus-up"]])

    def test_the_first_tab_of_the_next_group_is_not_this_groups_next_tab(self):
        windows = [tile(1, 0, active=True, tab_index=0), tile(1, 1, tab_index=0)]
        self.assertEqual(press(windows, "down"), [["window-focus-down"]])

    def test_a_tab_in_another_column_is_not_a_neighbour(self):
        windows = [tile(1, 0, active=True, tab_index=0), tile(2, 1, tab_index=1)]
        self.assertEqual(press(windows, "down"), [["window-focus-down"]])

    def test_outside_a_group_moves_focus(self):
        self.assertEqual(press([tile(1, 0, active=True), tile(1, 1)], "down"), [["window-focus-down"]])

    def test_with_nothing_focused_moves_focus(self):
        self.assertEqual(press([tile(1, 0)], "up"), [["window-focus-up"]])


if __name__ == "__main__":
    unittest.main()
