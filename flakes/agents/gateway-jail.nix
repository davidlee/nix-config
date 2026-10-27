# Gateway mode for one jail (see makeJailedAgent's `gateway` argument): its
# jail options, and the wrapper that checks the gateway is reachable before
# launch. No provider key.
{
  lib,
  pkgs,
  combinators,
  setenvsByArgsFd,
  clientSocket, # the relay's client socket (gateway.nix)
  socketOptions, # the in-jail forwarder to it (gateway-forwarder.nix)
  piGatewayModelsFor,
}: {
  name, # the jail's name
  gateway, # null, or { keyFile; url; runDirectory; }
  network, # the profile's network flag
  piInJail, # forced only when gateway is set
}: let
  # The shape is checked by `throw` before any attribute is read, so a bad
  # shape is an evaluation error a caller can observe, not an abort on a
  # missing attribute.
  attrNames = ["keyFile" "runDirectory" "url"];
  checked =
    if
      builtins.isAttrs gateway
      && lib.attrNames gateway == attrNames
      && lib.all builtins.isString (lib.attrValues gateway)
    then gateway
    else throw "jailed-${name}: gateway must be { keyFile; url; runDirectory; }, all strings";

  # The key is read by `$(< …)`, a shell builtin, inside the descriptor's
  # process substitution: it is in no process's argv. A second descriptor,
  # so it never shares 21 with provider keys.
  keyArgsFd = "22";

  # Socket mode: the profile's network flag alone selects it (DEC-076).
  socketMode = !network;

  # What the wrapper checks before launch: the directory the jail will reach
  # the gateway through.
  reachDirectory =
    if socketMode
    then dirOf clientSocket # the directory the forwarder binds
    else checked.runDirectory;

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
      ++ lib.optionals socketMode socketOptions
      ++ piOptions;

    # The outer launcher: checks only — it never reads the key — and names
    # the fix when the jail could not reach the gateway.
    wrap = inner:
      pkgs.writeShellScriptBin "jailed-${name}" ''
        key_file="${checked.keyFile}"
        if [ ! -r "$key_file" ] || [ ! -s "$key_file" ]; then
          echo "jailed-${name}: gateway key $key_file is missing, empty or unreadable." >&2
          echo "  Issue one: llm-gateway issue ${name} --models <a,b> --budget <usd> --out \"$key_file\"" >&2
          exit 1
        fi
        if [ ! -d ${lib.escapeShellArg reachDirectory} ]; then
          echo "jailed-${name}: the LLM gateway is not running (no ${reachDirectory})." >&2
          echo "  Not yet switched to a system with it: just system-switch" >&2
          echo "  Otherwise the service is failing: systemctl status llm-gateway" >&2
          echo "  (first run, no provider credential yet: just gateway-credentials)" >&2
          exit 1
        fi
        exec ${inner}/bin/jailed-${name} "$@"
      '';
  }
