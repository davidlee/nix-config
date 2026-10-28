# CHR-017: Python lint: ruff + pylint in the devshell and gate, then a lint pass

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`just fmt` runs alejandra, statix and deadnix only. The gateway's Python
(`features/agents/gateway/{gateway_hooks.py,keystore.py,price-check.py,llm-gateway,gateway-test,keystore-test}`)
has no linter or formatter in the gate; SL-014 workers ran ruff by hand. SL-014
design sec-6 assumed "ruff/nixfmt/statix (whatever `just lint` runs)", and there
is no `just lint`. Wire ruff check + format into treefmt (or the gate) so
Python drift fails like Nix drift.

## Widened 2026-10-28 (operator)

Scope is all of the repo's Python, not only the gateway: about 4,000 lines.
`gateway-test` alone is about 1,300.

```
features/agents/gateway/   gateway_hooks.py keystore.py price-check.py
                           llm-gateway llm-gateway-serve gateway-test keystore-test
features/audio/            dictate dictate-test
hosts/Sleipnir/doctor/     sleipnir-doctor sleipnir-doctor-panopticon doctor-test
```

Several are extensionless scripts with a python shebang, so the linters'
file selection must include them explicitly.

1. Tooling: add ruff and pylint to `devShells.default` (`perSystem.nix`).
   Shared config (a root `pyproject.toml` or `ruff.toml` + `.pylintrc`).
   Pylint needs each script's runtime imports (litellm, fastapi, httpx, yaml)
   to resolve; the gateway's `proxy.python` env is one source.
2. Gate: `ruff check` and `ruff format --check` in treefmt (`nix fmt`, the
   `treefmt` check). Pylint goes in the gate only if it runs offline against
   those envs and is fast enough; otherwise it runs from the devshell.
3. Lint pass: fix the findings, or suppress them with a stated reason.
   Known: `gateway-test` E402 (×6) is deliberate, because those imports
   follow the launcher's `sys.path` setup (2026-10-28). Expect a format
   churn commit; keep it separate from the fixes.

Unrelated drift seen in the same run: the `treefmt` check already fails on
`_templates/rust/shell.nix` (alejandra).
