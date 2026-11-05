# agents/quotient-in-jail.nix — the real quotient inside a jail.
#
#   host                                   jail (quotientServer = { package; forms; })
#   ~/.config/quotient/profiles ──ro-try──► ~/.config/quotient/profiles
#   store: quotient-jail-config ──ro─────► ~/.config/quotient   policy.json, profiles/
#                                           `quotient` on PATH: package
#                                             └─ forms ─► the family's read / write
#                                           claude, codex: the server registered
#
# The server runs nested, under a policy of the jail's own (DEC-123), where
# quotient-relay.nix reaches the host's. The config is read-only, so nothing
# in the jail can plant approvals; the profiles are the host's directory
# (DEC-126). `options` is the jail's side (what makeJailedAgent's
# `quotientServer` adds), `registration` is how an agent is told of the server.
#
# formStoreBinds is for every form, in a jail or not: what a form nested in a
# jail needs and cannot find for itself.
{
  lib,
  pkgs,
  combinators,
}: let
  # `etc-store-binds PATH...`: for each link under the paths, the store path it
  # resolves to, as NUL-separated bwrap words. A runtime arg, as the other
  # runtime binds are: quotient's check needs the form's bwrap line plain.
  etcStoreBinds = pkgs.writeShellScript "etc-store-binds" ''
    PATH=${lib.makeBinPath [pkgs.findutils pkgs.coreutils pkgs.gnused]}
    find "$@" -type l -exec readlink -f {} + 2>/dev/null |
      sed -n 's|^\(/nix/store/[^/]*\).*|\1|p' | sort -u |
      while read -r p; do printf '%s\0' --ro-bind-try "$p" "$p"; done
  '';

  # jail.nix's network combinator binds these /etc entries and follows their
  # store targets with `nix-store --query --requisites`. A jail has no store
  # database, so the query fails ("path … is not valid") and the form is left
  # with dangling links: no TLS, no /etc/hosts. This binds what the query would
  # have (DEC-125). On the host the database exists and this adds nothing.
  formStoreBinds = c: [
    (c.add-runtime ''
      if [ ! -e /nix/var/nix/db ]; then
        mapfile -d "" -t etc_binds < <(${etcStoreBinds} /etc/hosts /etc/nsswitch.conf /etc/resolv.conf /etc/ssl)
        RUNTIME_ARGS+=("''${etc_binds[@]}")
      fi
    '')
  ];

  # The policy the jail's quotient runs under. Two facts it rests on:
  # - The root stays /workspace. quotient looks for a project form at the
  #   longest root containing the call's root when no approval applies; with
  #   /workspace that is /workspace/.quotient/forms, which does not exist, so
  #   these forms run. Were the root the project, its host `.quotient/forms`
  #   link would be found unapproved and refused (form-unapproved).
  # - The maxima and the profile map copy the host policy's values. That is a
  #   dotfile outside the flake, so nothing here can read it. They are
  #   defaults for delegates (quotient:DEC-071), and a new profile needs a
  #   line here.
  policy = forms: {
    schema = "quotient-policy/2";
    mode = "per-call";
    enabled = true;
    roots = ["/workspace"];
    maxima = {
      requests = 60;
      context_tokens = 280000;
      cost_usd = 1.0;
      wall_clock_s = 900;
    };
    profiles = {
      read = "read";
      research = "read";
      review = "read";
      judgement = "read";
      write = "write";
      implement = "write";
    };
    forms = {
      read = "${forms.read}/bin/quotient-read";
      write = "${forms.write}/bin/quotient-write";
    };
    exposure = [];
    transcript_budget_bytes = 4096;
  };

  # Read-only over ~/.config/quotient, so nothing can plant approvals.json.
  # profiles/ is the mount point for the host's directory (DEC-126).
  config = forms:
    pkgs.runCommand "quotient-jail-config" {} ''
      mkdir -p $out/profiles
      cp ${pkgs.writeText "policy.json" (builtins.toJSON (policy forms))} $out/policy.json
    '';

  # How an agent learns of the server, chosen by the jail's name; any other
  # name registers nothing. set-argv replaces the entry's argv, and noescape
  # keeps the caller's arguments last.
  registration = package: let
    bin = "${package}/bin/quotient";
    mcpConfig = pkgs.writeText "quotient-mcp.json" (builtins.toJSON {mcpServers.quotient.command = bin;});
    caller = combinators.noescape ''"$@"'';
  in {
    # = is required: --mcp-config is variadic and would swallow what follows.
    claude = [(combinators.set-argv ["--mcp-config=${mcpConfig}" caller])];
    # codex filters an MCP child's env to HOME and PATH unless env_vars names more.
    codex = [
      (combinators.set-argv [
        "-c"
        ''mcp_servers.quotient.command="${bin}"''
        "-c"
        ''mcp_servers.quotient.env_vars=["LLM_GATEWAY_KEY","LLM_GATEWAY_URL"]''
        caller
      ])
    ];
  };

  # The jail's options for a server. After the persisted home's: bwrap mounts
  # in argv order, and the config must land on top of it. `~` is the same
  # string on both sides (SPEC-003 § The jail set), so one $HOME names the
  # host's profiles as source and the jail's as destination.
  options = {
    name,
    package,
    forms,
  }: let
    dir = "$HOME/.config/quotient";
  in
    with combinators;
      [
        (add-runtime ''
          RUNTIME_ARGS+=(--ro-bind ${config forms} "${dir}" --ro-bind-try "${dir}/profiles" "${dir}/profiles")
        '')
        (add-pkg-deps [package forms.read forms.write])
      ]
      ++ (registration package).${name} or [];
in {
  inherit etcStoreBinds formStoreBinds options policy;
}
