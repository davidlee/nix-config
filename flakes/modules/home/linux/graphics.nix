{
  pkgs,
  # stable,
  ...
}: {
  home.packages = with pkgs; [
    krita
    yed
  ];
}
