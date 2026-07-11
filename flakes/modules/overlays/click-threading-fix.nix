_: {
  # click-threading's pytest run collects docs/conf.py, which imports
  # pkg_resources (removed from a bare python3.14 env) and fails collection.
  # Upstream packaging bug, not our config; pulled in transitively via
  # dms-shell -> khal -> vdirsyncer -> sphinx-hook.
  flake.overlays.click-threading-fix = _final: prev: {
    python314 = prev.python314.override {
      packageOverrides = _pyFinal: pyPrev: {
        click-threading = pyPrev.click-threading.overridePythonAttrs (_: {
          doCheck = false;
        });
      };
    };
  };
}
