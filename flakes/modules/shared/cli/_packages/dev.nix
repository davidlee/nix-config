{pkgs, ...}: {
  common = with pkgs; [
    just
    exercism
    nodejs_latest # npx
    uv
    python3
    mise
    claude-monitor

    ## supervisors / runners
    overmind
    watch
    watcher
    watchexec
    fswatch
  ];
  linuxHome = with pkgs; [
    ccache

    ## supervisors / runners
    # watchman pulls the folly/fbthrift C++ tower, which currently
    # fails to build on aarch64-darwin; keep it Linux-only.
    watchman
  ];
  linuxSystem = with pkgs; [
    ## sandbox/container substrate
    bubblewrap
    distrobox
    distrobox-tui
    #devcontainer

    valgrind
    strace
  ];
}
