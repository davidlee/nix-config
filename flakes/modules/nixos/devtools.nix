_: {
  flake.nixosModules.devtools = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ## general utils
      treefmt
      just

      # ## SCM
      sublime-merge

      # ## lang.c
      valgrind
      strace

      ## database
      sqlite

      ## prog general
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

      # rust
      # crates-tui
    ];
  };
}
