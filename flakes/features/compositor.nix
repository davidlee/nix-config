# Compositors, in projection order (DEC-026). Shape: README § Feature tree.
# Each runs on the shared Wayland stack, so each requires desktop.core.
_: [
  (import ./compositor/sway.nix)

  # The home half's tailscale-systray and swaybg wallpaper also serve umbriel (ISS-008).
  {
    name = "niri";
    requires = ["desktop.core"];
    nixos = {pkgs, ...}: {
      programs = {
        niri = {
          enable = true;
          useNautilus = true;
        };
      };

      environment.systemPackages = with pkgs; [
        xwayland-satellite
        cosmic-edit
        cosmic-wallpapers
        nautilus
        nautilus-open-any-terminal
      ];
      security.pam.services.swaylock = {};

      services.gvfs.enable = true; # Enables Trash, network mounts, and storage detection
      services.tumbler.enable = true; # Enables image/video thumbnails in file managers
      programs.firefox.preferences = {
        # disable libadwaita theming for Firefox
        # "widget.gtk.libadwaita-colors.enabled" = false;
      };
    };
    homeManager = {
      pkgs,
      username,
      inputs,
      ...
    }: {
      home.packages = with pkgs; [nirius vicinae];

      imports = [
        inputs.vicinae.homeManagerModules.default
        # inputs.noctalia.homeModules.default
      ];

      services.tailscale-systray.enable = true;

      systemd.user.services.swaybg = {
        Unit = {
          Description = "wallpaper (swaybg)";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          Requisite = ["graphical-session.target"];
        };
        Service = {
          ExecStart = ''${pkgs.swaybg}/bin/swaybg -m fill -i "/home/${username}/Pictures/wallpaper/dark-water.jpg"'';
          Restart = "on-failure";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
  }

  {
    name = "cosmic";
    requires = ["desktop.core"];
    nixos = _: {
      services = {
        desktopManager.cosmic.enable = true;
      };

      programs.firefox.preferences = {
        # disable libadwaita theming for Firefox
        "widget.gtk.libadwaita-colors.enabled" = false;
      };
      environment.sessionVariables = {COSMIC_DATA_CONTROL_ENABLED = 1;};
    };
  }

  {
    name = "kde";
    requires = ["desktop.core"];
    nixos = {pkgs, ...}: {
      # services = {
      #   xserver.enable = true;
      #
      #   displayManager.sddm = {
      #     enable = true;
      #     wayland.enable = true;
      #     settings.General.DisplayServer = "wayland";
      #   };
      #
      #   desktopManager.plasma6.enable = true;
      # };

      # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";

      environment.systemPackages = with pkgs.kdePackages; [
        # kdeplasma-addons
        plasma-desktop

        pkgs.qt6Packages.qt6ct
        # plasma-systemmonitor
        # plasma-browser-integration
        # plasma-thunderbolt
        # plasma-vault
        plasma-workspace
        # plasma-workspace-wallpapers

        breeze
        breeze-icons
        breeze-gtk
        breeze-plymouth

        ksshaskpass
        kpkpass
        # kauth
        # kwallet-pam
        # kwalletmanager

        kiconthemes
        # kscreenlocker
        kwindowsystem
        kaccounts-providers

        kde-cli-tools
        # calendarsupport
        bluedevil
        bluez-qt
        # xwaylandvideobridge

        dolphin
        dolphin-plugins
        drkonqi

        #kate
        # kweather
        # gwenview
        # karchive
        # marknote
      ];

      # environment.plasma6.excludePackages = with pkgs.kdePackages; [
      #   plasma-browser-integration
      # ];
    };
  }

  {
    name = "mango";
    requires = ["desktop.core"];
    nixos = {inputs, ...}: {
      imports = [inputs.mangowm.nixosModules.mango];
      programs.mango.enable = true;
    };
  }

  {
    name = "umbriel";
    requires = ["desktop.core"];
    nixos = {inputs, ...}: {
      imports = [inputs.umbriel.nixosModules.default];
      programs.umbriel.enable = true;
      # there's also a HM module
    };
  }
]
