{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## supervisors / runners
    # direnv
    just
    overmind
    watch
    watchman
    watcher
    watchexec
    fswatch
  ];
}
