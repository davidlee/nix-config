{
  config,
  lib,
  pkgs,
  ...
}: {
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
      # Resolver tests. Evaluating them is the test; the build is a stub.
      features = let
        failures = import ./features-test.nix lib;
      in
        if failures == []
        then pkgs.runCommand "features-test" {} "touch $out"
        else throw "features-test.nix failed:\n${lib.generators.toPretty {} failures}";

      # hosts/<h>/meta.nix schema tests (host-meta.nix), shaped like checks.features.
      host-meta = let
        failures = import ./host-meta-test.nix lib;
      in
        if failures == []
        then pkgs.runCommand "host-meta-test" {} "touch $out"
        else throw "host-meta-test.nix failed:\n${lib.generators.toPretty {} failures}";
    }
    # The gateway is NixOS-only, so its check is Linux only.
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # llm-gateway's LiteLLM adapter, offline, against the system nixpkgs'
      # LiteLLM (gateway-test).
      llm-gateway = let
        gateway = ./features/agents/gateway;
        proxy = import (gateway + "/proxy.nix") {inherit pkgs lib;};
      in
        pkgs.runCommand "llm-gateway-test" {
          nativeBuildInputs = [proxy.python];
          LLM_GATEWAY_SERVE = gateway + "/llm-gateway-serve";
          LLM_GATEWAY_CONFIG = proxy.configDir {};
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
              model = "deepseek/no-such-model-host-override";
              provider = "deepseek";
            };
          });
        } ''
          # the sandbox points SSL_CERT_FILE at a missing file, and LiteLLM
          # builds an httpx client at import; the price map is the packaged one
          unset SSL_CERT_FILE
          export LITELLM_LOCAL_MODEL_COST_MAP=True
          python3 ${gateway + "/gateway-test"}
          grep -q 'not in the packaged price map: deepseek/no-such-model-host-override' \
            "$LLM_GATEWAY_UNPRICED/testBuildFailure.log"
          touch $out
        '';
    };
}
