# Review RV-041 — design of SL-019

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Review SL-019's complete design against its research, pinned LiteLLM 1.106.2,
the current gateway hooks, launcher, CLI and Nix composition, SPEC-001's client
contract, and DEC-073 / DEC-084..092. Concentrate on parser agreement across
content types and encodings, route/method and top-level field isolation,
nested image-fetch paths, zstd output and window bounds, complete-frame
validation, and request-header consistency after decoding. Check that the
proposed fake-upstream tests exercise authentication, model scope, provider
credentials and accounting. Synthetic probes use dummy data and no providers;
this is design verification, not implementation or rollout proof.

## Synthesis

**Overall:** acceptable at design level.

**Synopsis:** The revised design addresses F-1, F-2 and F-3 through canonical
JSON replay headers, an independent zstd window cap, and explicit handling of
all encoding-header occurrences. Isolated checks of the prescribed recipe
against the pinned parser/decoder support those repairs; no new defect was
established. These checks do not prove an implementation or deployment.
ISS-020 retains the live F-1 defect until rollout; the design's tests and
rollout obligations remain necessary. The review produced no additional work,
knowledge or open decision requiring another artifact.

**Haiku:**
Headers name the bytes  
Small frames meet a bounded gate  
Live code waits its turn
