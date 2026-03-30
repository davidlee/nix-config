_: {
  flake.homeModules.browsers = {
    pkgs,
    inputs,
    ...
  }: {
    home.packages = with pkgs; [
      # (callPackage ../../../pub/helium.nix {})
      ladybird
      vivaldi
      ungoogled-chromium
      inputs.hythera-nur.packages.${pkgs.system}.waterfox
    ];
  };
}
