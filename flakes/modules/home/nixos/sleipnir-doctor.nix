_: {
  # python3 interpreter comes from the sway module's wpmPython env (already on PATH).
  flake.homeModules.sleipnir-doctor = _: {
    home.file.".local/bin/sleipnir-doctor" = {
      source = ./bin/sleipnir-doctor;
      executable = true;
    };
  };
}
