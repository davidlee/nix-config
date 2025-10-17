{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      # others
      hyprlock
      hypridle
    ];

    services = {
      swayosd.enable = true;

      # for hypridle
      # let
      #   screen = "DP-3";
      # in
      # hypridle = {
      #   enable = true;
      #   settings = {
      #     general = {
      #       # after_sleep_cmd = "hyprctl dispatch dpms on";
      #       after_sleep_cmd = "wlopm --off ${screen}";
      #       ignore_dbus_inhibit = false;
      #       lock_cmd = "hyprlock";
      #     };
      #
      #     listener = [
      #       {
      #         timeout = 1200;
      #         on-timeout = "hyprlock";
      #       }
      #       {
      #         timeout = 1500;
      #         on-timeout = "wlopm --off ${screen}";
      #         on-resume = "wlopm --on ${screen}";
      #       }
      #     ];
      #   };
      # }; # hypridle
    }; # services
  }; # home-manager
}
