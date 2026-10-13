# python3 interpreter comes from the sway module's wpmPython env (already on PATH).
_: {
  home.file = {
    ".local/bin/sleipnir-doctor" = {
      source = ./bin/sleipnir-doctor;
      executable = true;
    };
    ".config/sleipnir-doctor/checks.d/emacs" = {
      source = ./bin/sleipnir-doctor-emacs;
      executable = true;
    };
    ".config/sleipnir-doctor/checks.d/panopticon" = {
      source = ./bin/sleipnir-doctor-panopticon;
      executable = true;
    };
  };
}
