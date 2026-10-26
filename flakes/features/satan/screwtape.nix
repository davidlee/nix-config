# screwtape — Belphegor's read-only JMAP mirror: a systemd user oneshot on a
# timer syncs a bounded Fastmail window into SQLite (screwtape SL-001).
#
# Source: ~/dev/screwtape (github: input, bin/dev-checkouts).
#
# State: ~/.local/state/screwtape/mail.sqlite3 (0700 directory).
# Credential: ~/.config/credstore.encrypted/screwtape.fastmail, written by
# `screwtape-provision` once per token rotation (1Password prompt).
#
# Smoke:
#   systemctl --user status screwtape.service
#   journalctl --user -u screwtape
#   screwtape mailboxes
{lib, ...}: {
  name = "screwtape";
  platforms = lib.platforms.linux;
  homeManager = {inputs, ...}: {
    imports = [inputs.screwtape.homeManagerModules.default];

    services.screwtape = {
      enable = true;
      # A reference, not the token: the read-only Fastmail API token.
      opRef = "op://SLEIPNIR_CREDENTIALS/udcn7s4ervqa3mrvadczu6lqoy/credential";
    };
  };
}
