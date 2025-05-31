{
  pkgs,
  username,
  ...
}:
{

  imports = [
    ../modules/shared-packages.nix   
  ];

  # system packages
  # 
  environment.systemPackages = with pkgs; [
    ## boot 
    greetd.greetd
    greetd.tuigreet

    # ## disk / io
    hdparm
    smartmontools
    udiskie

    # ## package management
    appimage-run
    devcontainer
    flatpak
    nix-janitor
    sd-switch

    ## network / http
    iptraf-ng
    nethogs
    nmon
    vnstat
    
    ## files / find
    fsearch
    plocate

    ## low level / system monitoring
    ccache
    cpuid
    cpuinfo
    dmidecode
    lshw
    pciutils
    smem
    stress-ng
    sysprof
    sysstat
    usbutils 
    x86info
    lm_sensors

    ## converters
    pandoc

    # ## download / backup
    backintime

    # ## docs, notes, productivity
    zeal
    dnote

    ## image / graphics / multimedia
    viu

    ## audio
    alsa-utils
    pipewire
    wireplumber
    
    ## media players
    mpv
    playerctl
    
    ## security / crypto / secrets
    keepassxc

    ## tasks
    taskchampion-sync-server

    ## frivolity
    fortune
    cmatrix
    nms
    openrgb-with-all-plugins

    # windows API 
    dotnet-runtime

    ### libs 
    glib
    libffi
    libiconv
    libyaml
    openssl
    openssl.dev
    pkg-config
    raylib
    zlib
    pixman
    SDL
    SDL2
    SDL2_mixer

  ];

  programs = {
    nix-ld.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
    _1password.enable = true;

    appimage.binfmt = true;
    appimage.enable = true;

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ username ];
    };
      
    rust-motd = { # fixme
      enable = true;
      settings = {
      };
    };
    
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
    };

    foot = {
      enable = true;
      theme = "gruvbox-dark";
      settings.main = {
        font = "Fira Code:size=11";
      #   main = {
      #     font = "Fira Code:size=11";
      #   };
      };
    };

    zsh = {
      enable = true;
    };

  };

  # allow non-root write access to firmware 
  hardware = {
    keyboard.qmk.enable = true;
  };

  environment.pathsToLink = [ "/share/zsh" ];
}
