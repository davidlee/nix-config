{inputs}: {
  config,
  lib,
  pkgs,
  ...
}: let
  # A test file (lib -> lib.runTests failures) as a check: evaluating it is the
  # test; the build is a stub named for the file.
  evalTests = file: let
    name = lib.removeSuffix ".nix" (baseNameOf file);
    failures = import file lib;
  in
    if failures == []
    then pkgs.runCommand name {} "touch $out"
    else throw "${name}.nix failed:\n${lib.generators.toPretty {} failures}";
in {
  treefmt.programs = {
    alejandra.enable = true;
    statix.enable = true;
    deadnix.enable = true;
  };
  devShells.default = pkgs.mkShell {
    packages = [config.treefmt.build.wrapper pkgs.gum pkgs.just pkgs.nix-output-monitor];
  };

  checks =
    {
      # Resolver tests.
      features = evalTests ./features-test.nix;
      # hosts/<h>/meta.nix schema tests (host-meta.nix).
      host-meta = evalTests ./host-meta-test.nix;
    }
    # The gateway is NixOS-only, so its check is Linux only.
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # The satan room's door data (features/satan/room.nix); the feature is Linux only.
      satan-room = evalTests ./features/satan/room-test.nix;

      # quotient's form contract over the machine-default family (agents.quotient).
      quotient-forms = inputs.quotient.lib.checkFormFamily {
        inherit pkgs;
        family = import ./features/agents/quotient/family.nix {inherit inputs pkgs;};
      };

      # llm-gateway's LiteLLM adapter, offline, against the system nixpkgs'
      # LiteLLM (gateway-test).
      llm-gateway = let
        gateway = ./features/agents/gateway;
        proxy = import (gateway + "/proxy.nix") {inherit pkgs lib;};

        # An id the price map lacks: the price-rule twins differ from
        # LLM_GATEWAY_UNPRICED only in the property under test (DEC-064).
        unmapped = "deepseek/no-such-model-host-override";
        bothPriced = {
          input_cost_per_token = 1.0e-7;
          output_cost_per_token = 2.0e-7;
        };
        # The fake OpenRouter gateway-test serves on loopback. The sandbox has
        # its own network namespace, so a fixed port cannot collide there.
        fakePort = 18471;
        onFake = m: m // {params = (m.params or {}) // {api_base = "http://127.0.0.1:${toString fakePort}/v1";};};
        # unmapped, so its cost can only come from the provider (DEC-064)
        reported = proxy.defaults.models."openrouter/~z-ai/glm-latest";

        # HALF_PRICED: one price is an evaluation error whatever the cost
        # source; each half has a both-priced twin that must evaluate, so a
        # refusal for any other reason cannot pass.
        halfPriced = let
          evaluates = m: (builtins.tryEval (proxy.configDir {models.half = m;}).drvPath).success;
          cases = {
            mapped = {
              model = "deepseek/deepseek-flash";
              provider = "deepseek";
            };
            unmapped = {
              model = unmapped;
              provider = "deepseek";
            };
            reportsCost = {
              model = unmapped;
              provider = "openrouter";
            };
          };
          results =
            lib.mapAttrs (_: m: {
              half = evaluates (m // {params.input_cost_per_token = 1.0e-7;});
              both = evaluates (m // {params = bothPriced;});
            })
            cases;
        in
          assert lib.assertMsg (results
            == lib.mapAttrs (_: _: {
              half = false;
              both = true;
            })
            cases)
          "checks.llm-gateway: HALF_PRICED want every half refused and every twin admitted, got ${builtins.toJSON results}"; results;
      in
        pkgs.runCommand "llm-gateway-test" {
          nativeBuildInputs = [proxy.python];
          LLM_GATEWAY_SERVE = proxy.serve proxy.defaults.providers {};
          LLM_GATEWAY_CONFIG = proxy.configDir {};
          LLM_GATEWAY_REPORTS_COST =
            builtins.toJSON (lib.mapAttrsToList (_: p: p.env)
              (lib.filterAttrs (_: p: p.reportsCost or false) proxy.defaults.providers));
          LLM_GATEWAY_MODELS =
            builtins.toJSON (lib.mapAttrs (_: m: proxy.defaults.providers.${m.provider}.env or null) proxy.defaults.models);
          LLM_GATEWAY_TEST_CONFIG = proxy.configDir {
            extraModels.unpriced = {
              model = "deepseek/no-such-model-gateway-test";
              provider = "deepseek";
            };
            extraParams.mock_response = "mock_response from the test config";
          };
          # RV-026 F-5: a host's own unpriced model fails its build.
          LLM_GATEWAY_UNPRICED = pkgs.testers.testBuildFailure (proxy.configDir {
            models.unpriced = {
              model = unmapped;
              provider = "deepseek";
            };
          });
          # ...unless its provider reports cost, or it sets both prices.
          LLM_GATEWAY_REPORTED = proxy.configDir {
            models.reported = {
              model = unmapped;
              provider = "openrouter";
            };
          };
          LLM_GATEWAY_EXPLICIT = proxy.configDir {
            models.explicit = {
              model = unmapped;
              provider = "deepseek";
              params = bothPriced;
            };
          };
          LLM_GATEWAY_HALF_PRICED = builtins.toJSON halfPriced;
          # Models routed to the fake, on their production params, and no
          # mock_response: it would answer before any upstream call.
          LLM_GATEWAY_FAKE_PORT = toString fakePort;
          LLM_GATEWAY_FAKE_CONFIG = proxy.configDir {
            models = {};
            extraModels = lib.mapAttrs (_: onFake) {
              inherit reported;
              # LiteLLM strips the api_base's /v1 and appends /v1/systemone
              "typesafe/jev-1.14.0" = proxy.defaults.models."typesafe/jev-1.14.0";
              # the subscription, priced in params: one mapped, one not
              inherit (proxy.defaults.models) "chatgpt/gpt-6.1-sol" "chatgpt/gpt-6.1-terra";
              # its twin without allowed_openai_params
              unallowed = removeAttrs reported ["params"];
              # never requested: its params try to replace its model and key
              override = {
                model = "openrouter/local/override";
                provider = "openrouter";
                params = {
                  api_key = "sk-test-not-a-secret";
                  model = "openrouter/elsewhere";
                };
              };
            };
          };
        } ''
          # the sandbox points SSL_CERT_FILE at a missing file, and LiteLLM
          # builds an httpx client at import; the price map is the packaged one
          unset SSL_CERT_FILE
          export LITELLM_LOCAL_MODEL_COST_MAP=True
          python3 ${gateway + "/gateway-test"}
          grep -q 'not in the packaged price map: ${unmapped}' \
            "$LLM_GATEWAY_UNPRICED/testBuildFailure.log"
          touch $out
        '';
    };
}
