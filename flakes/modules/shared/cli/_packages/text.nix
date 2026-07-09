{pkgs, ...}: {
  ## text processing, calc, clock/cal
  common = with pkgs; [
    gnused
    sd
    gawk
    play # playground for sed, grep, awk, ...
    aspell
    choose
    slides

    ## calc
    bc
    eva
    sc-im

    ## clock
    clock-rs

    ## cal
    # calendar-cli # disabled: test failures in python3.13-niquests dep
    calcure
  ];
}
