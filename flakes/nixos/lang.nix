{pkgs, ...}: {
  #
  # ONLY stuff that's really necessary system-wide here
  # for everything else use dev shells
  #
  environment.systemPackages = with pkgs; [
    ## programming - general
    exercism

    ## lang.go
    go

    ## lang.ruby
    ruby
    bundler
    # rake
    # rbenv

    ## lang.python
    uv

    ## javascript
    corepack_latest
    nodejs_latest
    bun
    pnpm
  ];
}
