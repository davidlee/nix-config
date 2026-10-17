# agents/gateway.nix — where the local LLM gateway is, what it serves, and
# how pi talks to each model. Plain data: the gateway service, its checks and
# every jail import it; nothing copies it.
rec {
  runtimeDirectory = "llm-gateway"; # /run/<this>; the unit's RuntimeDirectory=
  socket = "/run/${runtimeDirectory}/api.sock";
  relayPort = 4000; # 4001 is taken on Sleipnir
  url = "http://127.0.0.1:${toString relayPort}/v1";
  keyDirectory = "$HOME/.config/llm-gateway/keys"; # expanded by the jail wrapper's shell

  # gateway model name -> LiteLLM model id, the provider whose key it uses,
  # and pi's entry for it, optional: without `pi` the model is served but not
  # offered to pi (DEC-066). The entry (DEC-063) is copied from pi's built-in
  # entry for the upstream model, checked through the gateway; LiteLLM's price
  # map has no compat or thinking levels.
  models.deepseek-flash = {
    model = "deepseek/deepseek-flash";
    provider = "deepseek";
    pi = {
      name = "DeepSeek V4.1 Flash";
      reasoning = true;
      input = ["text" "image"];
      contextWindow = 1000000;
      maxTokens = 384000;
      thinkingLevelMap = {
        minimal = null;
        low = "low";
        medium = null;
        high = "high";
        max = "max";
      };
      compat = {
        supportsStore = false;
        supportsDeveloperRole = false;
        maxTokensField = "max_tokens";
        requiresReasoningContentOnAssistantMessages = true;
        thinkingFormat = "deepseek";
        supportsStrictMode = true;
      };
    };
  };

  # A jail's `gateway` argument for one client. The client name is the key
  # file's name. The key in it is first issued under the same ledger alias;
  # a rotation re-issues it under a new alias into the same file (DEC-051).
  client = name: {
    keyFile = "${keyDirectory}/${name}";
    inherit url;
    runDirectory = "/run/${runtimeDirectory}";
  };
}
