# The scripts use only the standard library; python3 comes from PATH
# (dev.runtimes, through personal). SL-008 P7 pins the interpreter.
_: {
  home.file = {
    ".local/bin/sleipnir-doctor" = {
      source = ./doctor/sleipnir-doctor;
      executable = true;
    };
    ".config/sleipnir-doctor/checks.d/emacs" = {
      source = ./doctor/sleipnir-doctor-emacs;
      executable = true;
    };
    ".config/sleipnir-doctor/checks.d/panopticon" = {
      source = ./doctor/sleipnir-doctor-panopticon;
      executable = true;
    };
  };
}
