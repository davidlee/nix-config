_: {
  #  flake.flakeModules.lix = {inputs, ...}: {
  #    imports = [
  #      inputs.flake-parts.flakeModules.easyOverlay
  #    ];
  #    perSystem = {config, pkgs, final, ...}: {
  #    overlayAttrs = {
  #      # inherit (config.packages) my-package;
  # (final: prev: {
  #        inherit
  #          (prev.lixPackageSets.stable)
  #          nixpkgs-review
  #          nix-eval-jobs
  #          nix-fast-build
  #          colmena
  #          ;
  #      })
  #
  #    };
  #    }
  #  };
  #   withEachSystem,
  #   pkgs,
  #   inputs,
  #   ...
  # }: {
  #   #pkgs
  #   inputs.nixkpgs.overlays = [
  #     (final: prev: {
  #       inherit
  #         (prev.lixPackageSets.stable)
  #         nixpkgs-review
  #         nix-eval-jobs
  #         nix-fast-build
  #         colmena
  #         ;
  #     })
  #   ];
  # };
}
