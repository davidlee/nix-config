
{ 
  pkgs,
  inputs,
  username,
  ...
}: {

  home-manager.users.${username} = {
    home.packages = with pkgs; [
     

    
      # daw & audio
      # jack2
      # puredata-with-plugins
      carla
      reaper
      bitwig-studio      
      renoise
      lmms 
      zrythm
      ardour
      hydrogen
      audacity
      yoshimi
      qtractor
      rakarrack
      guitarix
      supercollider-with-plugins
      chuck
      
     
      # graphics & 3d
      blender
      gimp-with-plugins
      krita
      inkscape
      darktable
      ansel
      digikam
      penpot-desktop
      pikopixel

      # media players
      vlc
      kodi-wayland
      # kodi-cli
      celluloid
      mpv
      kdePackages.gwenview

      # video
      shotcut
      
      # util
      _1password-gui      
      virt-viewer 
      upscayl
      evince
      persepolis
      qbittorrent
      calibre
      flameshot
      ventoy-full
      artha
      guvcview
      inxi
      easyeffects

      # productivity
      thunderbird
      evolution
      morgen
      zotero
      foliate
      onlyoffice-bin
      libreoffice
      minder
      gnome-frog
      papers

      # games
      retroarch-full
      limo    
      lutris
      gamehub

      # messaging / social
      newsflash
      discord
      beeper
      signal-desktop
      slack
      rambox
      telegram-desktop

      # music player & library management
      beets
      fooyin
      quodlibet
      spotify
      tauon
      tokei
      deadbeef
      cantata
      
      # terminals
      alacritty
      wezterm
      foot
      ghostty
      kitty
      rio

      # editors
      neovim-gtk
      emacs-gtk
      obsidian
      code-cursor
      vscode
      zed-editor
      joplin
      claude-code
      # vscode-extensions.saoudrizwan.claude-dev
      # vscodium
            
      # browsers
      inputs.zen-browser.packages.${pkgs.system}.default
      vivaldi
      ladybird
      librewolf
      firefox
      qutebrowser
      floorp
      ungoogled-chromium
      palemoon-bin
      tor-browser
      # midori
    ];
  };
}
