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
      nerd-fonts.hack
      nerd-fonts.tinos
      nerd-fonts.agave
      nerd-fonts.profont
      nerd-fonts.iosevka
      nerd-fonts.hasklug
      nerd-fonts.zed-mono
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

}
