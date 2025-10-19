_: {
  flake.flakeModules.cliPackages = {
    pkgs,
    lib,
    ...
  }: let
    props = ["zsh" "pagers" "markdown" "help" "viewers" "unix" "filetypes"];
  in {
    options.sharedCliPackages = lib.genAttrs props (name:
      lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      });

    options.nixosCliPackages = lib.genAttrs props (name:
      lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      });

    config.sharedCliPackages.filetypes = with pkgs; [
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
      tidy-viewer

      ## JSON / YAML
      jqp # jq
      otree # text object tree viewer
      jq
      yq-go
    ];

    config.nixosCliPackages.filetypes = with pkgs; [
      csv-tui
    ];

    # flake.darwinModules.cli-text = {pkgs, ...}: {
    #   environment.systemPackages = config.sharedCliPackages pkgs;
    # };
    #
    # flake.nixosModules.cli-text = {pkgs, ...}: {
    #   environment.systemPackages = (config.sharedCliPackages.filetypes ++ config.nixosCliPackages.filetypes) pkgs;
    # };
  };

  # eachSystem =
  flake.nixosModules.cliPackages = {
    self,
    config,
    ...
  }: let
    allSharedPackages = config.sharedCliPackages.filetypes;
    allNixosPackages = config.nixosCliPackages.filetypes;
  in {
    imports = [
      self.flakeModules.cliPackages
    ];

    environment.systemPackages = allSharedPackages ++ allNixosPackages; # config.sharedCliPackages.filetypes ++ config.nixosCliPackages.filetypes;
  };

  flake.darwinModules.cliPackages = {
    self,
    config,
    ...
  }: let
    allSharedPackages = config.sharedCliPackages.filetypes;
  in {
    imports = [
      self.flakeModules.cliPackages
    ];

    environment.systemPackages = allSharedPackages;
  };
}
