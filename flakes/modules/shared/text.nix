_: let
  textPackages = pkgs:
    with pkgs; [
      ## unix / text
      coreutils
      gnused
      gawk
      bat
      emacsclient-commands
      lsd
      eza
      chroma
      sd

      ## json/yaml
      jq
      yq-go

      ## markdown
      markdownlint-cli
      markdownlint-cli2
      markdown-oxide
      marksman

      ## markdown
      frogmouth
      glow
      marked-man
      md-tui

      ## CSV
      csv-tui
      tidy-viewer

      ## JSON
      jqp # jq
      otree # text object tree viewer

      ## text readers, pagers
      # fltrdr
      nvimpager
      less
      most
      moar
      viddy
      ov

      ## English
      vale
      # vale-ls
      aspell

      ## typing
      thokr
      ngrrram
    ];
in {
  flake.nixosModules.text = {pkgs, ...}: {
    environment.systemPackages = textPackages pkgs;
  };

  flake.darwinModules.text = {pkgs, ...}: {
    environment.systemPackages = textPackages pkgs;
  };
}
