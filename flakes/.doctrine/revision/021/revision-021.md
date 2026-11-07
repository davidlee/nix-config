# REV REV-021 — SPEC-001 and SPEC-002: drop retired OpenRouter param and speech target

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

Operator-agreed backlog burn-down, 2026-11-08.

- SPEC-001 § served models: CHR-025 drops `allowed_openai_params` from OpenRouter entries;
  LiteLLM 1.108.0's `OpenrouterConfig` supports `reasoning_effort` on every model. The
  ChatGPT entry that sets it is unchanged.
- SPEC-001 § LiteLLM upgrades: the memory was re-checked in part on 1.108.0 (CHR-024).
- SPEC-002 § Concerns: IMP-039 removes the redundant `Sleipnir+speech` target.
