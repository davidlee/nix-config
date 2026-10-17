# agents/gateway.nix — where the local LLM gateway is, what it serves, and
# how pi talks to each model. Plain data: the gateway service, its checks and
# every jail import it; nothing copies it.
rec {
  runtimeDirectory = "llm-gateway"; # /run/<this>; the unit's RuntimeDirectory=
  socket = "/run/${runtimeDirectory}/api.sock";
  relayPort = 4000; # 4001 is taken on Sleipnir
  url = "http://127.0.0.1:${toString relayPort}/v1";
  keyDirectory = "$HOME/.config/llm-gateway/keys"; # expanded by the jail wrapper's shell

  # gateway model name (DEC-069: <gateway provider>/<upstream id>) -> LiteLLM
  # model id, the provider whose key it uses, and two optional entries:
  # `params`, merged into its LiteLLM params under the model and key
  # (DEC-070); and `pi`, pi's entry for it: without `pi` the model is served
  # but not offered to pi (DEC-066). The pi entry (DEC-063) is copied from
  # pi's built-in entry for the upstream model, checked through the gateway;
  # LiteLLM's price map has no compat or thinking levels.
  models = let
    # OpenRouter prices each request itself. reasoning_effort must be allowed
    # explicitly: LiteLLM refuses it (400) for a model its map does not flag
    # as reasoning, and most routes here are unmapped or aliases.
    openrouter = id: {
      model = "openrouter/${id}";
      provider = "openrouter";
      params.allowed_openai_params = ["reasoning_effort"];
    };
    routed = ids:
      builtins.listToAttrs (map (id: {
          name = "openrouter/${id}";
          value = openrouter id;
        })
        ids);
  in
    {
      deepseek-flash = {
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
      # in the packaged price map, flagged supports_reasoning: no params
      "fireworks/nemotron-lightning-3p5-30b-a3b" = {
        model = "fireworks_ai/accounts/fireworks/models/nemotron-lightning-3p5-30b-a3b";
        provider = "fireworks";
      };
    }
    // routed [
      "~deepseek/deepseek-flash-latest"
      "~deepseek/deepseek-pro-latest"
      "deepseek/deepseek-v4.1-flash"
      "deepseek/deepseek-v4-flash"
      "openrouter/auto"
      "openrouter/free"
      "openrouter/pareto-code"
      "qwen/qwen3.8-flash"
      "z-ai/glm-5.3-flash"
      "~z-ai/glm-flash-latest"
      "~z-ai/glm-latest"
      "google/gemini-3.8-flash"
      "google/gemini-3-flash-preview"
      "xiaomi/mimo-v2.6-pro"
      "xiaomi/mimo-v2.6-flash"
    ];

  # A jail's `gateway` argument for one client. The client name is the key
  # file's name. The key in it is first issued under the same ledger alias;
  # a rotation re-issues it under a new alias into the same file (DEC-051).
  client = name: {
    keyFile = "${keyDirectory}/${name}";
    inherit url;
    runDirectory = "/run/${runtimeDirectory}";
  };
}
