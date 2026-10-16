# The python scripts use only the standard library; their shebang is pinned to
# the store python3, so the doctor does not depend on PATH (SL-008 P7). The
# emacs provider is bash and stays as written.
{pkgs, ...}: let
  pinnedPython = name: file:
    pkgs.writeScript name (builtins.replaceStrings
      ["#!/usr/bin/env python3"]
      ["#!${pkgs.python3.interpreter}"]
      (builtins.readFile file));
in {
  home.file = {
    ".local/bin/sleipnir-doctor" = {
      source = pinnedPython "sleipnir-doctor" ./doctor/sleipnir-doctor;
      executable = true;
    };
    ".config/sleipnir-doctor/checks.d/emacs" = {
      source = ./doctor/sleipnir-doctor-emacs;
      executable = true;
    };
    ".config/sleipnir-doctor/checks.d/panopticon" = {
      source = pinnedPython "sleipnir-doctor-panopticon" ./doctor/sleipnir-doctor-panopticon;
      executable = true;
    };
  };
}
