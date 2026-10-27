# IMP-046: W3 — Agents lib helper for quotient confinement forms

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W3. Three implementations of a quotient form family exist:
- screwtape: `quotient.lib.mkFormFamily { pkgs; jail-nix; pi = jailLib.unjailed.pi; packages; env.LLM_GATEWAY_URL; secretEnv.LLM_GATEWAY_KEY; piFiles."models.json" = jailLib.piGatewayModels; }` — ~10 lines, the newest pattern.
- satan: hand-rolled `quotientFormFamily` on `makeJailedPi`.
- doctrine: an "interim copy" of satan's, already marked for retirement
  (`doctrine:CHR-183`).

Want: a helper in the agents lib that wraps `mkFormFamily` with the gateway
wiring, so a project's form is a few lines and duplicates as little of the
jail as possible. satan and doctrine then retire their copies (in W5,
CHR-023).

Done: `quotientFormFamily` in `agents/jailed-agents.nix`, exported by the
lib. It calls `quotient.lib.mkFormFamily` with the lib's `pkgs`, `jail-nix`
and `unjailed.pi`, and merges the gateway client's (default `pi`) URL, key
and `models.json` into the caller's `env`, `secretEnv` and `piFiles`; every
other arg passes through. `quotient` is passed in (flake or lib), so the
agents flake takes no quotient input. `network = false` is refused: the
gateway is TCP. Tested in `jailed-agents-test.nix` against a stub
`mkFormFamily`; documented in `agents/README.md` § quotient forms.
- screwtape migrated (flake.nix: the call is now `inherit quotient;
  packages = …;`, and its `jail-nix` input is dropped). Its
  `quotient-read`/`quotient-write` drvPaths are identical before and after,
  against the local agents. Its commit waits on the agents push, so its lock
  can name a remote agents rev that has the helper.
- satan and doctrine keep their hand-rolled copies until W5 (CHR-023).
  Not yet checked: whether their extras (doctrine's
  `CARGO_BUILD_RUSTFLAGS` forward, satan's `specDev` profile) map onto
  `mkFormFamily`'s `options`/`env`.

Resolved 2026-10-27.
