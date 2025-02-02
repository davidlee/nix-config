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
      noto-fonts-emoji
      noto-fonts-cjk-sans
      font-awesome
      symbola
      material-icons
      fira-code
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
      jetbrains-mono
      monaspace
      geist-font
    ];
  };
  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;

  # options = {users.enable = lib.mkEnableOption "Enables users module";};

  # config = lib.mkIf config.users.enable {
  
}
