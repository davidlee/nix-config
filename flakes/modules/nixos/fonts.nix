_: {
  flake.nixosModules.fonts = {
    pkgs,
    stable,
    ...
  }: {
    console = {
      font = "${pkgs.terminus_font}/share/consolefonts/ter-124n.psf.gz";
      keyMap = "us";
      packages = with pkgs; [
        terminus_font
      ];
    };

    fonts = {
      packages = with pkgs; [
        # Sans-serif (UI / body)
        inter
        ibm-plex
        roboto
        ubuntu-classic
        geist-font
        dejavu_fonts
        liberation_ttf

        # Serif (long-form text)
        source-serif
        libertinus
        libertine
        libre-baskerville
        libre-caslon
        libre-bodoni
        eb-garamond
        gelasio
        et-book # org

        # Monospace (code / terminal)
        stable.jetbrains-mono
        iosevka
        cascadia-code
        fira-code
        fira-code-symbols
        source-code-pro
        ubuntu-sans-mono
        victor-mono
        monaspace
        proggyfonts
        mplus-outline-fonts.githubRelease

        # Nerd Fonts (patched glyphs for editors/terminals)
        nerd-fonts.noto
        nerd-fonts.hack
        nerd-fonts.tinos
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

        # CJK
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        # Emoji & symbols
        noto-fonts-color-emoji
        symbola

        # Icon fonts
        font-awesome
        material-icons

        # Console / bitmap
        terminus_font
        terminus_font_ttf
        termsyn
        tamsyn
        dina-font

        # Display / specialty
        (pkgs.callPackage ../../pub/clockface-font.nix {})
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [
            "Inter"
            "IBM Plex Sans"
            "Noto Sans"
            "Noto Sans CJK SC"
            "Noto Color Emoji"
          ];
          serif = [
            "Source Serif 4"
            "Libertinus Serif"
            "Noto Serif"
            "Noto Serif CJK SC"
            "Noto Color Emoji"
          ];
          monospace = [
            "JetBrainsMono Nerd Font"
            "JetBrains Mono"
            "Iosevka"
            "Noto Sans Mono CJK SC"
            "Noto Color Emoji"
          ];
          emoji = ["Noto Color Emoji"];
        };
      };

      fontDir.enable = true;
      enableDefaultPackages = true;
    };
  };
}
