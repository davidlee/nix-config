{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.umbriel.nixosModules.default];
  programs.umbriel.enable = true;
  # there's also a HM module
}
