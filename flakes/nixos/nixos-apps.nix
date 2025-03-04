
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
      pikopixel

      # util
      _1password-gui      
      virt-viewer 

      # games
      limo    
      lutris
      gamehub

      # messaging
      discord
      beeper
      signal-desktop
      slack

      # music 
      beets
      fooyin
      quodlibet
      spotify
      tauon
      tokei
      
      # terminals
      alacritty
      wezterm
      foot
      ghostty
      kitty

      # editors
      obsidian
      code-cursor
      vscode
      zed-editor
      
      # office
      thunderbird
      morgen
      
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
      # midori
    ];
  };
}
