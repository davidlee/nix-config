# agents/gateway.nix — where the local LLM gateway is, what it serves, and
# how pi talks to each model. Plain data: the gateway service, its checks and
# every jail import it; nothing copies it.
rec {
  runtimeDirectory = "llm-gateway"; # /run/<this>; the unit's RuntimeDirectory=
  socket = "/run/${runtimeDirectory}/api.sock";
  # User-owned client listener on the relay (DEC-075); shared by the system and
  # home evaluations (ADR-004 D4).
  clientRuntimeDirectory = "llm-gateway-client";
  clientSocket = "/run/${clientRuntimeDirectory}/api.sock";
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
    # TypeSafe's Jev: a native LiteLLM provider on /v1/systemone, priced from
    # the packaged map (input tokens only). Not offered to pi: no chat.
    typesafe = id: {
      model = "typesafe/${id}";
      provider = "typesafe";
    };
    # OpenAI, on one account's key. The id stays bare, as the packaged price
    # map keys it, so the provider is named. `pi` entries are pi-ai 1.4.0's
    # built-in openai-responses entries, cut to the completions route the
    # gateway serves: their cost tiers start at 272k input tokens, which the
    # context window never reaches, so they are left out. gpt-6.1-terra has
    # neither a built-in entry nor a price-map entry: its prices are OpenAI's
    # standard tier (no batch, flex or fast use), the rest is gpt-6.1-sol's.
    openaiModels = let
      # off maps to "none" where the model can switch reasoning off
      levels = off: max: {
        inherit off max;
        minimal = null;
        low = "low";
        medium = "medium";
        high = "high";
        xhigh = "xhigh";
      };
      # USD per million tokens
      cost = input: output: cacheRead: cacheWrite: {inherit input output cacheRead cacheWrite;};
      model = name: contextWindow: cost: thinkingLevelMap: {
        inherit name contextWindow cost thinkingLevelMap;
        maxTokens = 128000;
      };
    in {
      gpt-6-luna.pi = model "GPT-6 Luna" 272000 (cost 0.1 0.5 0.01 0.125) (levels "none" "max");
      "gpt-6.1-sol".pi = model "GPT-6.1 Sol" 272000 (cost 2 10 0.1 2.5) (levels null "max");
      gpt-6-astra.pi = model "GPT-6 Astra" 272000 (cost 10 50 1 12.5) (levels null "max");
      "gpt-5.4-mini".pi = model "GPT-5.4 mini" 400000 (cost 0.75 4.5 0.075 0) (levels "none" null);
      "gpt-6.1-terra" = {
        pi = model "GPT-6.1 Terra" 272000 (cost 1 5 0.05 1.25) (levels null "max");
        params = {
          # unmapped: LiteLLM refuses reasoning_effort unless allowed (DEC-074)
          allowed_openai_params = ["reasoning_effort"];
          input_cost_per_token = 1.0e-6;
          output_cost_per_token = 5.0e-6;
          cache_read_input_token_cost = 5.0e-8;
          input_cost_per_token_above_272k_tokens = 2.0e-6;
          output_cost_per_token_above_272k_tokens = 7.5e-6;
          cache_read_input_token_cost_above_272k_tokens = 1.0e-7;
        };
      };
    };
    # pi's completions compat for OpenAI behind the gateway: no `store` and no
    # 24h cache retention, neither on the gateway's chat field list.
    openaiCompat = {
      supportsStore = false;
      supportsDeveloperRole = true;
      supportsLongCacheRetention = false;
      supportsMidConvoSystemMessages = true;
      supportsStrictMode = true;
      maxTokensField = "max_completion_tokens";
      thinkingFormat = "openai";
    };
    openai = provider: id: let
      m = openaiModels.${id};
    in {
      model = id;
      inherit provider;
      params = {custom_llm_provider = "openai";} // (m.params or {});
      pi =
        m.pi
        // {
          name = "${m.pi.name} (${provider})";
          reasoning = true;
          input = ["text" "image"];
          compat = openaiCompat;
        };
    };
    account = provider: named provider (openai provider) (builtins.attrNames openaiModels);
    # named <provider>/<id> (DEC-069)
    named = provider: helper: ids:
      builtins.listToAttrs (map (id: {
          name = "${provider}/${id}";
          value = helper id;
        })
        ids);
    routed = named "openrouter" openrouter;
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
          # USD per million tokens. pi-ai 1.3.0's built-in deepseek-flash and
          # LiteLLM 1.102.1's price map (deepseek/deepseek-flash, what the
          # gateway bills against a key's budget) agree, 2026-10-19. The
          # satan-runner's cost ceiling reads it (DEC-057): never under-count.
          cost = {
            input = 0.3;
            output = 1.2;
            cacheRead = 0.006;
            cacheWrite = 0;
          };
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
      # panopticon-digest (SL-009): strict json_schema output.
      "openai/gpt-4.1-mini"
    ]
    // named "typesafe" typesafe [
      "jev-latest"
      "jev-preview"
      "jev-1.14.0"
      "jev-1.13.0"
    ]
    // account "openai-dav"
    // account "openai-david";

  # A jail's `gateway` argument for one client. The client name is the key
  # file's name. The key in it is first issued under the same ledger alias;
  # a rotation re-issues it under a new alias into the same file (DEC-051).
  client = name: {
    keyFile = "${keyDirectory}/${name}";
    inherit url;
    runDirectory = "/run/${runtimeDirectory}";
  };
}
