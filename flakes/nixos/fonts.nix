{
  pkgs,
  username,
  lib,
  config,
  inputs,
  ...
}: {
  # Fonts
  # 
  fonts = {
    packages = with pkgs; [
      font-awesome
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      font-awesome
      ubuntu_font_family
      symbola
      material-icons
      mplus-outline-fonts.githubRelease
      fira-code
      fira-code-symbols
      proggyfonts
      noto-fonts
      nerd-fonts.noto 
      nerd-fonts.hack 
      nerd-fonts.tinos 
      nerd-fonts.mplus 
      nerd-fonts.lilex 
      nerd-fonts.arimo 
      nerd-fonts.agave 
      nerd-fonts._3270 
      nerd-fonts.ubuntu 
      nerd-fonts.monoid 
      nerd-fonts.lekton 
      nerd-fonts.hurmit 
      nerd-fonts.profont 
      nerd-fonts.monofur 
      nerd-fonts.iosevka 
      nerd-fonts.hasklug 
      nerd-fonts.go-mono 
      nerd-fonts.cousine 
      nerd-fonts.zed-mono 
      nerd-fonts.overpass 
      victor-mono
      terminus_font
      jetbrains-mono
      monaspace
      dina-font
      geist-font
      
    ];
  };
  
  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;

  fonts.fontconfig.enable = true; 
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Noto Sans" ];
  fonts.fontconfig.defaultFonts.serif = [ "Noto Serif" ];
  fonts.fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];


}
