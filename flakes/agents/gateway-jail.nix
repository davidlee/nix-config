# Gateway mode for one jail (see makeJailedAgent's `gateway` argument): its
# jail options, the entry wrap that must come last, and the wrapper that
# checks the gateway is reachable before launch. No provider key.
{
  lib,
  pkgs,
  combinators,
  setenvsByArgsFd,
  clientSocket, # the relay's client socket (gateway.nix)
  socketForwarder, # source: the forwarder to it, { bind; entry; } (gateway-forwarder.nix)
  piGatewayModelsFor,
}: {
  name, # the jail's name
  gateway, # null, or { keyFile; url; runDirectory; clientDirectory?; }
  network, # the profile's network flag
  piInJail, # forced only when gateway is set
}: let
  # The shape is checked by `throw` before any attribute is read, so a bad
  # shape is an evaluation error a caller can observe, not an abort on a
  # missing attribute.
  attrNames = ["keyFile" "runDirectory" "url"];
  shaped =
    if
      builtins.isAttrs gateway
      && lib.elem (lib.attrNames gateway) [attrNames (["clientDirectory"] ++ attrNames)]
      && lib.all builtins.isString (lib.attrValues gateway)
    then gateway
    else throw "jailed-${name}: gateway must be { keyFile; url; runDirectory; clientDirectory?; }, all strings";
  # clientDirectory is the host side of socket mode's one bind: with network
  # there is no such bind for it to source.
  checked =
    if shaped ? clientDirectory && !socketMode
    then throw "jailed-${name}: gateway.clientDirectory needs a profile without network (socket mode)"
    else shaped;

  # The key is read by `$(< …)`, a shell builtin, inside the descriptor's
  # process substitution: it is in no process's argv. A second descriptor,
  # so it never shares 21 with provider keys.
  keyArgsFd = "22";

  # Socket mode: the profile's network flag alone selects it (DEC-076).
  socketMode = !network;

  # The host source of the client socket's directory: the real one, or
  # clientDirectory, a shell word the launcher expands (as keyFile is), set
  # only by check variants (nemesis:SL-026 PHASE-02 EX-5, DEC-131).
  clientDirectory = checked.clientDirectory or null;
  forwarder = socketForwarder clientDirectory;

  # What the wrapper checks before launch: the directory the jail will reach
  # the gateway through, as shown and as tested.
  reachDirectory =
    if !socketMode
    then checked.runDirectory
    else if clientDirectory == null
    then dirOf clientSocket # the directory the forwarder binds
    else clientDirectory;
  reachTest =
    if clientDirectory == null
    then lib.escapeShellArg reachDirectory
    else "\"${clientDirectory}\"";

  # pi reads its providers only from ~/.pi/agent/models.json, which the
  # persisted home shares with every jail on it: bind the generated one over
  # it, read-only. Must follow the persisted-home bind, or that bind would
  # cover it (as hostGitExcludesOptions). No seed for a missing target: a
  # host-side write inside the jail-writable home would follow a symlink the
  # jail planted (RV-028 F-1).
  piOptions = lib.optionals piInJail [
    (combinators.unsafe-add-raw-args "--ro-bind ${piGatewayModelsFor checked.url} ~/.pi/agent/models.json")
  ];
in
  if gateway == null
  then {
    options = [];
    entryOptions = [];
    wrap = inner: inner;
  }
  else {
    options =
      [
        (combinators.set-env "LLM_GATEWAY_URL" checked.url)
        (setenvsByArgsFd keyArgsFd {
          LLM_GATEWAY_KEY = "\"$(< \"${checked.keyFile}\")\"";
        })
      ]
      ++ lib.optionals socketMode forwarder.bind
      ++ piOptions;

    # The forwarder's entry wrap: the jail applies it after every other
    # option, so it is the outermost wrap and any caller's wrap-entry runs
    # once the gateway is reachable (IMP-075).
    entryOptions = lib.optionals socketMode forwarder.entry;

    # The outer launcher: checks only — it never reads the key — and names
    # the fix when the jail could not reach the gateway.
    wrap = inner:
      pkgs.writeShellScriptBin "jailed-${name}" ''
        key_file="${checked.keyFile}"
        if [ ! -r "$key_file" ] || [ ! -s "$key_file" ]; then
          echo "jailed-${name}: gateway key $key_file is missing, empty or unreadable." >&2
          echo "  Issue one: llm-gateway issue <fresh-alias> --models <a,b> --budget <usd> --out \"$key_file\"" >&2
          echo "  (a revoked alias is never reissued: llm-gateway list shows those taken)" >&2
          exit 1
        fi
        if [ ! -d ${reachTest} ]; then
          echo "jailed-${name}: the LLM gateway is not running (no ${reachDirectory})." >&2
          echo "  Not yet switched to a system with it: just system-switch" >&2
          echo "  Otherwise the service is failing: systemctl status llm-gateway" >&2
          echo "  (first run, no provider credential yet: just gateway-credentials)" >&2
          exit 1
        fi
        exec ${inner}/bin/jailed-${name} "$@"
      '';
  }
