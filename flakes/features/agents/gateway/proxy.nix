# The LiteLLM proxy the gateway serves (design SL-011 sec-2): its Python
# environment, its launcher, the default models and providers, and the config
# directory (config.yaml beside gateway_hooks.py and keystore.py, which
# LiteLLM loads from the directory of CONFIG_FILE_PATH). Used by
# checks.llm-gateway and by the NixOS record, so both run the same
# composition.
{
  pkgs,
  lib,
}: rec {
  python = pkgs.python3.withPackages (ps: [ps.litellm] ++ ps.litellm.optional-dependencies.proxy);

  # The launcher, llm-gateway-serve, with PROVIDERS baked from `providers`
  # (credential name -> variable) and any other `values` (the service's
  # SOCKET).
  serve = providers: values:
    import ./bake.nix {inherit pkgs lib;} "llm-gateway-serve" python
    ({PROVIDERS = lib.mapAttrs (_: p: p.env) providers;} // values);

  defaults = {
    # gateway model name -> LiteLLM model id, the provider whose key it uses
    # and its optional `params`, from agents/gateway.nix (its `pi` entries
    # are for pi, not LiteLLM)
    models = lib.mapAttrs (_: m: removeAttrs m ["pi"]) (import ../../../agents/gateway.nix).models;
    # provider -> the variable LiteLLM reads its key from (the credential is
    # named after the provider) and its 1Password reference (public, G1);
    # reportsCost: the provider returns each request's billed cost and
    # LiteLLM captures it, so its models need no price (DEC-064)
    providers = {
      deepseek = {
        env = "DEEPSEEK_API_KEY";
        ref = "op://API_KEYS/DEEPSEEK_API_KEY/credential";
      };
      openrouter = {
        env = "OPENROUTER_API_KEY";
        ref = "op://API_KEYS/OPENROUTER_API_KEY/credential";
        reportsCost = true;
      };
      fireworks = {
        env = "FIREWORKS_API_KEY";
        ref = "op://API_KEYS/FIREWORKS_API_KEY/credential";
      };
      typesafe = {
        env = "TYPESAFE_API_KEY";
        # by convention; confirm the item at rollout (SL-019 ASM-002)
        ref = "op://API_KEYS/TYPESAFE_API_KEY/credential";
      };
      # two OpenAI accounts, one key each, the same models (DEC-069 names)
      openai-dav = {
        env = "OPENAI_DAV_API_KEY";
        ref = "op://API_KEYS/OPENAI_API_KEY/credential";
      };
      openai-david = {
        env = "OPENAI_DAVID_API_KEY";
        ref = "op://API_KEYS/OPENAI_ALT_API_KEY/credential";
      };
    };
  };

  # No secret reaches the store: keys are os.environ/<env> references
  # (POL-001 r1), and there is no master_key (DEC-050). A model's `params`
  # are merged under the generated keys, so they cannot replace its model
  # or key (DEC-070). `extraParams` is merged over every model's
  # litellm_params; it and `extraModels` exist for the check, which adds
  # mock_response without touching the mapping.
  # Cost source, per model (DEC-064): its provider reports cost, or it sets
  # both prices, or the build checks it is in LiteLLM's packaged price map,
  # which prices an absent one at 0 (RV-026 F-5). Setting one price is an
  # evaluation error naming the model, for every model, `extraModels` too;
  # those are exempt only from the map check, so the check can serve an
  # unpriced one.
  configDir = {
    models ? defaults.models,
    providers ? defaults.providers,
    extraModels ? {},
    extraParams ? {},
  }: let
    prices = m: lib.filter (f: (m.params or {}) ? ${f}) ["input_cost_per_token" "output_cost_per_token"];
    checkPrices = name: m:
      assert lib.assertMsg (lib.length (prices m) != 1)
      "llm-gateway: model ${name} sets only one of input_cost_per_token, output_cost_per_token"; m;
    needsMap = m: !(providers.${m.provider}.reportsCost or false) && lib.length (prices m) != 2;
    entry = name: raw: let
      m = checkPrices name raw;
    in {
      model_name = name;
      litellm_params =
        (m.params or {})
        // {
          inherit (m) model;
          api_key = "os.environ/${providers.${m.provider}.env}";
        }
        // extraParams;
    };
    config = {
      model_list = lib.mapAttrsToList entry (models // extraModels);
      general_settings = {
        custom_auth = "gateway_hooks.authenticate";
        # No master key (DEC-050): custom_auth authenticates every request
        # the route gate admits, before any master-key comparison
        # (proxy/auth/user_api_key_auth.py:1637, 1.106.2). This flag is read
        # only by the boot check that otherwise refuses to start without one
        # (proxy/auth/master_key_boot_check.py).
        dangerously_permit_weak_or_unset_master_key = true;
      };
      litellm_settings.callbacks = ["gateway_hooks.model_gate" "gateway_hooks.ledger"];
    };
    yaml = (pkgs.formats.yaml {}).generate "config.yaml" config;
  in
    pkgs.runCommand "llm-gateway-config" {} ''
      ${python.interpreter} ${./price-check.py} ${lib.escapeShellArgs (map (m: m.model) (lib.filter needsMap (lib.attrValues models)))}
      mkdir $out
      cp ${yaml} $out/config.yaml
      cp ${./gateway_hooks.py} $out/gateway_hooks.py
      cp ${./keystore.py} $out/keystore.py
    '';
}
