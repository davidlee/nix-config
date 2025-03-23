{
  pkgs,
  ...
}: {

  # console.font = "Lat2-Terminus16";

  console = {
    font = "ter-124b";
    keyMap = "us";
    packages = with pkgs; [
      terminus_font
    ];
  };
   
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
      termsyn
      tamsyn
      terminus_font_ttf
      jetbrains-mono
      monaspace
      dina-font
      geist-font
    ];

    fontconfig = {
      enable = true; 
      defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
      defaultFonts.sansSerif = [ "Noto Sans" ];
      defaultFonts.serif = [ "Noto Serif" ];
      defaultFonts.emoji = [ "Noto Color Emoji" ];
    };

    fontDir.enable = true;
    enableDefaultPackages = true;
  };
}
