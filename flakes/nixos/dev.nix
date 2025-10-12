{pkgs, ...}: {
  imports = [
    ../modules/shared-development.nix
  ];

  environment.systemPackages = with pkgs; [
    # ## ai
    # local-ai
    # lmstudio
    # vllm

    # ## SCM
    sublime-merge

    # ## keyboard firmware
    qmk-udev-rules

    # ## lang.c
    valgrind
    strace
  ];
}
