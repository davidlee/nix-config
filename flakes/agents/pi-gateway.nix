# pi's provider for an LLM gateway (DEC-058): one provider, named apart
# from every built-in so no stored auth.json credential matches it.
# baseUrl is literal (pi does not interpolate it); apiKey is read from the
# environment per request. `models` is gateway.nix's shape: each served
# model's `pi` block is its pi entry (DEC-063); a model without one is not
# offered to pi (DEC-066). Shared by the jails (jailed-agents.nix) and the
# satan-runner unit (features/satan/runner.nix): one render, never copied.
{lib}: url: models: {
  providers.llm-gateway = {
    baseUrl = url;
    api = "openai-completions";
    apiKey = "$LLM_GATEWAY_KEY";
    models =
      lib.mapAttrsToList (id: m: {inherit id;} // m.pi)
      (lib.filterAttrs (_: m: m ? pi) models);
  };
}
