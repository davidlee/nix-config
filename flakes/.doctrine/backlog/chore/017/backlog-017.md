# CHR-017: Lint and format the gateway Python in just fmt / just test

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`just fmt` runs alejandra, statix and deadnix only. The gateway's Python
(`features/agents/gateway/{gateway_hooks.py,keystore.py,price-check.py,llm-gateway,gateway-test,keystore-test}`)
has no linter or formatter in the gate; SL-014 workers ran ruff by hand. SL-014
design sec-6 assumed "ruff/nixfmt/statix (whatever `just lint` runs)", and there
is no `just lint`. Wire ruff check + format into treefmt (or the gate) so
Python drift fails like Nix drift.
