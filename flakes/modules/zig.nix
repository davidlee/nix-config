({ inputs, pkgs, ... }: let
  system = pkgs.system;
  zig = inputs.zig-overlay.packages.${system}.master;
in {
  nixpkgs.overlays = [
    (self: super: {
      inherit zig;
      zls = inputs.zls-overlay.packages.${system}.zls.overrideAttrs (finalAttrs: prevAttrs: {
        nativeBuildInputs = [ zig ];
      });
    })
  ];

  # environment.systemPackages = [ zig zls pkgs.zig-shell-completions ];
})
