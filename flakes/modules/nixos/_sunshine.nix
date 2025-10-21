_: {
  flake.nixosModules.sunshine = {
    pkgs,
    username,
    ...
  }: {
    services = {
      sunshine = {
        enable = true;
        openFirewall = true;
        capSysAdmin = true;
        # capSysNice = true;
        autoStart = false;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        moonlight-qt
        sunshine
      ];
    };
  };
}
