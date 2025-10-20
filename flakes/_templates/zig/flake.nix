{
  inputs = {
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls-overlay.url = "github:zigtools/zls";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    zig-overlay,
    zls-overlay,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    zig = zig-overlay.packages.${system}.master;
  in {
    nixpkgs.overlays = [
      (self: super: {
        inherit zig;
        zls = zls-overlay.packages.${system}.zls.overrideAttrs (finalAttrs: prevAttrs: {
          nativeBuildInputs = [zig];
        });
      })
    ];

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        zig
        zls-overlay.packages.${system}.zls
        pkgs.zig-shell-completions
      ];
    };
  };
}
