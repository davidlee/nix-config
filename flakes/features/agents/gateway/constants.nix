# Where the gateway is reached (design SL-011 sec-2, sec-5): plain data, no
# arguments, so the NixOS record and the jail's clients import the same
# values. The literals live here only.
rec {
  runtimeDirectory = "llm-gateway"; # /run/<this>; the unit's RuntimeDirectory=
  socket = "/run/${runtimeDirectory}/api.sock";
  relayPort = 4000; # 4001 is taken on Sleipnir
  url = "http://127.0.0.1:${toString relayPort}/v1";
  keyDirectory = "$HOME/.config/llm-gateway/keys"; # expanded by the jail wrapper's shell (sec-5)
}
