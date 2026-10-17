# The LiteLLM proxy the gateway serves (design SL-011 sec-2): its Python
# environment, the default models and providers, and the config directory
# (config.yaml beside gateway_hooks.py and keystore.py, which LiteLLM loads
# from the directory of CONFIG_FILE_PATH). Used by checks.llm-gateway and by
# the NixOS record, so both run the same composition.
{
  pkgs,
  lib,
}: rec {
  python = pkgs.python3.withPackages (ps: [ps.litellm] ++ ps.litellm.optional-dependencies.proxy);

  defaults = {
    # gateway model name -> LiteLLM model id and the provider whose key it uses
    models = {
      deepseek-flash = {
        model = "deepseek/deepseek-flash";
        provider = "deepseek";
      };
    };
    # provider -> the variable LiteLLM reads its key from (the credential is
    # named after the provider) and its 1Password reference (public, G1)
    providers.deepseek = {
      env = "DEEPSEEK_API_KEY";
      ref = "op://API_KEYS/DEEPSEEK_API_KEY/credential";
    };
  };

  # No secret reaches the store: keys are os.environ/<env> references
  # (POL-001 r1), and there is no master_key (DEC-050). `extraParams` is
  # merged into every model's litellm_params; it and `extraModels` exist for
  # the check, which adds mock_response without touching the mapping.
  configDir = {
    models ? defaults.models,
    providers ? defaults.providers,
    extraModels ? {},
    extraParams ? {},
  }: let
    entry = name: m: {
      model_name = name;
      litellm_params =
        {
          inherit (m) model;
          api_key = "os.environ/${providers.${m.provider}.env}";
        }
        // extraParams;
    };
    config = {
      model_list = lib.mapAttrsToList entry (models // extraModels);
      general_settings.custom_auth = "gateway_hooks.authenticate";
      litellm_settings.callbacks = ["gateway_hooks.model_gate" "gateway_hooks.ledger"];
    };
    yaml = (pkgs.formats.yaml {}).generate "config.yaml" config;
  in
    pkgs.runCommand "llm-gateway-config" {} ''
      mkdir $out
      cp ${yaml} $out/config.yaml
      cp ${./gateway_hooks.py} $out/gateway_hooks.py
      cp ${./keystore.py} $out/keystore.py
    '';
}
