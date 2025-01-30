# yEdit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_AU.UTF-8";
  #   LC_IDENTIFICATION = "en_AU.UTF-8";
  #   LC_MEASUREMENT = "en_AU.UTF-8";
  #   LC_MONETARY = "en_AU.UTF-8";
  #   LC_NAME = "en_AU.UTF-8";
  #   LC_NUMERIC = "en_AU.UTF-8";
  #   LC_PAPER = "en_AU.UTF-8";
  #   LC_TELEPHONE = "en_AU.UTF-8";
  #   LC_TIME = "en_AU.UTF-8";
  # };

  boot.kernelParams = ["nvidia_drm.fbdev=1" "nvidia-drm.modeset=1"];
  
  services.xserver = {
    videoDrivers = [ "nvidia"];
    # enable = true; 
    # displayManager.gdm = {
    #   enable = true;
    #   wayland = true;
    # };
  };

  # programs.niri.enable = true;
  
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "hourly";
    # localuser = null;
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.videoDrivers = ["nvidia"];


  # # Configure keymap in X11
  # services.xserver.xkb = {
  #   layout = "us";
  #   variant = "";
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  hardware.graphics = {
    enable = true;
  };
 
  hardware.nvidia = {
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # prime = {
    #   intelBusId = "";
    #   nvidiaBusId = "";
    # }
  };

  # services.emacs.enable = true; # for emacsclient

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.david = {
    isNormalUser = true;
    description = "David";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  # users.defaultUserShell = pkgs.zsh;
  # services.blueman.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim
    neovim
    neovim-gtk
    lsd
    helix
    wget
    tree
    ncdu
    emacs
    dolphin
    nnn
    ranger
    python312
    python312Packages.pywatchman
    pstree
    pipx
    libGL
    sqlite
    tpnote
    ruby
    findutils
    plocate
    zk
    vivaldi
    kitty
    ghostty
    alacritty
    obsidian
    marksman
    swaylock
    swayidle
    swaybg
    waybar
    dmenu
    i3status
    foot
    mako
    shotman
    keepassxc
    polkit
    dconf
    xwayland
    mesa
    # nerdfonts
    zsh
    wine
    nix-search-cli
    rofi-wayland
    gnumake
    tasksh
    taskwarrior3
    gh
    lazygit
    delta
    ncdu
    wofi
    bitwarden-cli
    bitwarden-desktop
    htop
    exercism
    git
    pipewire
    wireplumber
    hyprland
    hyprls
    hypre
    hyprdim
    hyprsome
    hyprshot
    hyprnome
    hyprlock
    hyprlang
    hypr
    hyprkeys
    hyprutils
    hyprspace
    hyprpaper
    hyprsunset
    hyprnotify
    hyprcursor
    hyprlandPlugins.hyprscroller
    hyprpolkitagent
    hyprland-activewindow
    wl-clipboard
    wl-clipboard-rs
    clipse
    copyq
    clipman
    xdg-desktop-portal-hyprland
    discord
    slack
    signal-desktop
    spotify
    pastel
    fd
    mods
    local-ai
    xh
    aria2
    glow
    bat
    rathole
    sn0int
    nmap
    bottom
    broot
    btop
    syncthing
    duf
    beeper
    autoconf
    glfw
    eza
    file
    gawk
    gnused
    graphviz
    hexyl
    direnv
    difftastic
    d2
    caddy
    semgrep
    aspell
    gitu
    httpie
    ictree
    jq
    just
    kakoune
    marksman
    nethack
    gnumake
    valgrind
    lldb
    ols
    pipx
    p7zip
    qmk
    raylib
    ripgrep
    stow
    tldr
    xfce.thunar
    tmux
    vit
    nil
    tpnote
    tree-sitter
    unar
    unzip
    vit
    watchman
    wezterm
    which
    xz
    yazi
    yq-go
    zig
    zls
    zstd
    zellij
    gcc
    clang
    bison
    binutils
    llvm
    nwg-look
    bibata-cursors
    phinger-cursors
    ungoogled-chromium
    grim
    slurp
    wl-clipboard
    lutris
    pciutils
    _1password-gui
    _1password-cli
    rustup
    fuzzel
    cmake
    meson
    cpio
  ];


  fonts.packages = with pkgs; [
    # nerd-fonts
    proggyfonts
    noto-fonts
  ];

  fonts.enableDefaultPackages = true;

  # users.defaultUserShell = pkgs.zsh;

  # programs.sway = {
  #   enable = true;
  #   # wrapperFeatures.gtk = true; 
  # };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  hardware.steam-hardware.enable = true;

  programs.nix-ld.enable = true;

  programs.hyprland = { 
    enable = true; 
    withUWSM = true;
  #   # xwayland.enable = false; # conflict w niri
  };

  programs.zsh.enable = true;



  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # services.hypridle.enable = true;


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  environment.pathsToLink = [ "/share/zsh" ];

  security.sudo.wheelNeedsPassword = false;
  

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
