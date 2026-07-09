{pkgs, ...}: {
  common = with pkgs; [
    just
    exercism
    nodejs_latest # npx
    uv
    python3
    mise
    claude-monitor
  ];
  linuxHome = with pkgs; [
    ccache
  ];
  linuxSystem = with pkgs; [
    valgrind
    strace
  ];
}
