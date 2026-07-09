{lib, ...}: let
  categories = [
    "zsh"
    "shell-ux"
    "text"
    "fileutils"
    "find"
    "scm"
    "dev"
    "build"
    "system"
    "containers"
    "net"
    "security"
    "supervisors"
    "display"
    "filetypes"
    "editors"
    "www"
    "frivolity"
    "help"
  ];

  buckets = ["common" "linuxHome" "linuxSystem"];

  #
  # flatten cliPackages.<bucket> (an attrset keyed by category) into one list
  #
  collectBucket = bucket: config: lib.lists.flatten (lib.attrsets.attrValues config.cliPackages.${bucket});
in {
  flake.flakeModules.cliPackages = {
    pkgs,
    lib,
    ...
  }: let
    packageData = lib.genAttrs categories (name: import (./_packages + "/${name}.nix") {inherit pkgs lib;});
  in {
    #
    # cliPackages.<bucket>.<category>, type-safe, generated from `categories` above.
    #
    # common      - portable userland CLI tools (both platforms), owned by Home Manager
    # linuxHome   - Linux-only userland CLI tools, owned by Home Manager
    # linuxSystem - Linux-only machine/admin substrate, owned by NixOS environment.systemPackages
    #
    options.cliPackages = lib.genAttrs buckets (
      _bucket:
        lib.genAttrs categories (
          _name:
            lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [];
            }
        )
    );

    config.cliPackages = lib.genAttrs buckets (
      bucket: lib.genAttrs categories (name: packageData.${name}.${bucket} or [])
    );
  };

  #
  # import homeModules.cliPackages for portable + Linux-only userland CLI preferences.
  # import nixosModules.cliPackages for Linux machine/admin substrate.
  # or, just import flakeModules.cliPackages and cherry-pick via config.cliPackages.<bucket>.<category>
  #
  flake.homeModules.cliPackages = {
    self,
    config,
    pkgs,
    ...
  }: {
    imports = [self.flakeModules.cliPackages];
    home.packages = collectBucket "common" config ++ lib.optionals pkgs.stdenv.isLinux (collectBucket "linuxHome" config);
  };

  flake.nixosModules.cliPackages = {
    self,
    config,
    ...
  }: {
    imports = [self.flakeModules.cliPackages];
    environment.systemPackages = collectBucket "linuxSystem" config;
  };

  # No darwinModules: linuxSystem is Linux-only substrate, and portable CLI
  # tools reach Darwin via homeModules.cliPackages (wired in darwin/home.nix).
}
