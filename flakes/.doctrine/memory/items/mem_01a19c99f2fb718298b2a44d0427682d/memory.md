`argparse.ArgumentParser.format_help()` wraps to `shutil.get_terminal_size()`, which honours `COLUMNS` and the tty, and only falls back to 80 when neither is available. A test that `assertIn`s a sentence from that help passes on a wide terminal and fails on a narrow one — the sentence arrives split across lines with continuation indentation, so the assertion is width-dependent, not behaviour-dependent.

Seen in `features/agents/gateway/keystore-test::test_help_line`: green at `COLUMNS=80`, red at 40–60, which is how it surfaced as the last red gate test after an unrelated fix (the reporter's terminal is narrower than the agent's).

Fix shape — collapse before comparing, so the assertion holds at every width:

```python
help_text = " ".join(gateway.parser().format_help().split())
self.assertIn("replace a key's model list (the key is unchanged)", help_text)
```

Pin `COLUMNS` instead only if the wrapping itself is the behaviour under test; for "the help documents X" it is not.

Same trap in any repo test over argparse/subcommand help, `--help` snapshots, or anything else rendered through `format_help`/`textwrap`. `just test` inherits the caller's terminal, so a green run proves little about a narrow one — checking at `COLUMNS=40` is the cheap regression.