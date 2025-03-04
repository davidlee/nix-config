
{ 
  pkgs,
  inputs,
  username,
  ...
}: {

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      blender

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
