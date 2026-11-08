"""Tests for toggle-window-scratchpad, against the pad rules in the real apps.toml. Run: python3 -m unittest -v"""

import unittest

import fake_umbriel

_path = fake_umbriel.script("toggle-window-scratchpad")
_ONEPASSWORD = "com.onepassword.OnePassword"


def window(app_id="firefox", title="", scratchpad="", active=True):
    return {"app_id": app_id, "title": title, "scratchpad": scratchpad, "active": active}


def press(*windows, fallback="main"):
    """The `umbriel msg` arguments sent for one press."""
    calls = fake_umbriel.run(_path, list(windows), fallback)
    assert all(call[:2] == ["umbriel", "msg"] for call in calls), calls
    return [call[2:] for call in calls]


def toggle(pad):
    return [["window-toggle-scratchpad", pad]]


class ToggleWindowScratchpad(unittest.TestCase):
    def test_a_workspace_window_with_no_pad_rule_moves_to_the_fallback_pad(self):
        self.assertEqual(press(window(), fallback="secondary"), toggle("secondary"))

    def test_a_workspace_window_with_a_pad_rule_moves_to_that_pad(self):
        self.assertEqual(press(window("signal"), fallback="secondary"), toggle("signal"))

    def test_a_window_in_a_pad_moves_out_whatever_the_fallback_pad(self):
        self.assertEqual(press(window(scratchpad="main"), fallback="secondary"), toggle("main"))

    def test_a_window_in_another_pad_moves_out(self):
        self.assertEqual(press(window("signal", scratchpad="signal")), toggle("signal"))

    def test_a_window_in_a_pad_other_than_its_rules_moves_out(self):
        self.assertEqual(press(window("signal", scratchpad="main")), toggle("main"))

    def test_a_rule_can_match_on_title(self):
        self.assertEqual(press(window(_ONEPASSWORD, title="All Items")), toggle("onepassword"))

    def test_the_umbriel_controller_frame_moves_to_its_pad(self):
        self.assertEqual(press(window("emacs", title="umbriel-controller")), toggle("umbriel"))

    def test_any_other_emacs_frame_moves_to_the_fallback_pad(self):
        self.assertEqual(press(window("emacs", title="*scratch* - GNU Emacs")), toggle("main"))

    def test_a_window_failing_part_of_a_rules_match_moves_to_the_fallback_pad(self):
        self.assertEqual(press(window(_ONEPASSWORD, title="1Password")), toggle("main"))

    def test_only_the_focused_window_counts(self):
        self.assertEqual(press(window("signal", active=False), window()), toggle("main"))

    def test_with_nothing_focused_does_nothing(self):
        self.assertEqual(press(window(active=False)), [])


if __name__ == "__main__":
    unittest.main()
