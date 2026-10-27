# terminal.amenities' home module; imported by features/terminal.nix.
# Each tool hooks into every enabled shell: Home Manager's
# enable<Shell>Integration defaults to true and only takes effect where
# programs.<shell> is enabled, so selecting terminal.zsh or terminal.nushell
# is what wires them in. Set a flag only where it differs from that default.
{
  programs = {
    carapace.enable = true;
    zoxide.enable = true;

    # this was a piece of shit to get working
    # should do something neater than a hacked version of M365Princess theme
    # but I lost enthusiasm
    oh-my-posh = {
      enable = true;
      settings = builtins.fromJSON (
        builtins.readFile ../../files/omp.custom.json
      );
    };
    eza = {
      enable = true;
      enableNushellIntegration = true; # off by default: shadows nu's ls
    };
    fzf = {
      enable = true;
      historyWidget.command = "";
    };
    atuin = {
      enable = true;
      flags = ["--disable-up-arrow"];
    };
    television.enable = true;
    lazygit.enable = true;
  };
}
