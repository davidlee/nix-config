"""Test fixture: run a script against a fake `umbriel` on PATH."""

import json
import os
import pathlib
import subprocess
import sys
import tempfile

# Stands in for `umbriel` and for launched apps: serves `umbriel windows`,
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


def script(name):
    return str(pathlib.Path(__file__).with_name(name))


def run(path, windows, *args):
    """Run `path` with `windows` as the window list; return the argv of each command it ran."""
    with tempfile.TemporaryDirectory() as tmp:
        fake = pathlib.Path(tmp)
        for name in ("umbriel", "fake-app"):
            (fake / name).write_text(_FAKE)
            (fake / name).chmod(0o755)
        (fake / "windows.json").write_text(json.dumps(windows))
        env = {**os.environ, "FAKE_DIR": tmp, "XDG_RUNTIME_DIR": tmp, "PATH": f"{tmp}:{os.environ['PATH']}"}
        subprocess.run([path, *args], env=env, check=True)
        calls = fake / "calls"
        return [json.loads(line) for line in calls.read_text().splitlines()] if calls.exists() else []
