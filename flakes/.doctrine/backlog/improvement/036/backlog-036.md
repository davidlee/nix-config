# IMP-036: Jail tests: pure twins, a literal models.json oracle, a launcher-following check helper

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

From SL-013 audit RV-030 F-5 and F-4.

- `agents/jailed-agents-test.nix`: `piNoGateway` (real `agents`) and its twin
  `probeGateway` (`fakeBwrapAgents`) differ in bwrap and the op-run outer, not
  only in the gateway. Build both from the same agents set.
- `expectedPiModels` rebuilds models.json with the same `mapAttrsToList`
  expression as the code. Assert the content literally (`deepseek-flash`, its
  compat and thinkingLevelMap) so the test is an independent oracle.
- The missing-pi-entry message is unchecked (`tryEval` drops it). A check
  outside `tryEval` (eval stderr) would hold design sec-6's "fails naming x".
- PHASE-05 needed an ad-hoc script that follows `bin/jailed-*`'s exec to the
  real launcher before grepping bwrap args; make it a test helper in agents.
