{pkgs, ...}: {
  ## supervisors / runners
  common = with pkgs; [
    overmind
    watch
    watcher
    watchexec
    fswatch
  ];
  linuxHome = with pkgs; [
    # watchman pulls the folly/fbthrift C++ tower, which currently
    # fails to build on aarch64-darwin; keep it Linux-only.
    watchman
  ];
}
