{...}: {
  flake.nixosModules._1password = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      _1password-cli
      _1password-gui
    ];

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          firefox
          floorp
          vivaldi-bin
          zen
        '';
        mode = "0755";
      };
    };
  };
}
