# Desktop features, in projection order. Shape: README § Feature tree. The
# shared Wayland stack (core), the login screen (greeter) and fonts;
# compositors and the shell are areas of their own (DEC-026).
{lib, ...}: [
  (import ./desktop/core.nix {inherit lib;})

  # The login screen: noctalia's greeter on greetd. No requires (DEC-026).
  {
    name = "greeter";
    nixos = {
      config,
      lib,
      pkgs,
      username,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        greetd
        tuigreet
      ];

      #
      # Noctalia greeter
      #
      services.displayManager.noctalia-greeter = {
        enable = true;
        settings = {
          cursor.size = 24;
          keyboard.layout = "us";
          # The host's preselected session (services.displayManager.defaultSession,
          # which NixOS asserts names an installed session); unset, noctalia decides.
          default =
            lib.mkIf (config.services.displayManager.defaultSession != null)
            config.services.displayManager.defaultSession;
          # default_session = username;
          user.default = username;
          appearance = {
            scheme = "Synced";
          };
        };
        cursorTheme = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
        };
      };

      #
      # greetd
      #
      systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal"; # Without this errors will spam on screen
        # Without these bootlogs will spam on screen
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };

      console = {
        earlySetup = true;
        enable = true;
      };
    };
  }

  (import ./desktop/fonts.nix)
]
