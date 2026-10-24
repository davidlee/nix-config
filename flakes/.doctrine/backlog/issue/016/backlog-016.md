# ISS-016: chatgpt 26.1021.22027 fails to build: libtss2 missing

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Found 2026-10-24 on Sleipnir, after a lock bump moved `llm-agents` to
`92dd5ad` (upstream commit a2a444ef96, `chatgpt: 26.1016.61520 -> 26.1021.22027`).
`just home-switch` fails building `chatgpt-unwrapped-26.1021.22027`: the
fixup pass `auto-formatelf` cannot find `libtss2-esys.so.0`, `libtss2-mu.so.0`
and `libtss2-tcti-device.so.0` (from `tpm2-tss`), wanted by the new
`resources/native/remote-control-device-key.node`. The package does not list
`tpm2-tss` as an input. No upstream issue existed at the time.

Workaround, one site: `hosts/Sleipnir/features.nix` sets
`feature.agents.chatgpt.enable = false` over the `personal-linux` default.
`features-test.nix` no longer lists `agents.chatgpt#homeManager` among
Sleipnir's selections (two lists); restore both with the override's removal.

No probe: the workaround registry covers only the nixpkgs pins and
cache.nixos.org (IMP-041).

Done when: an `llm-agents` bump builds `pkgs.llm-agents.chatgpt` on
x86_64-linux, the override is removed and the test lists restored, and `just home-switch`
succeeds. Alternative fix: add `tpm2-tss` to `chatgpt-unwrapped`'s
`buildInputs` (here as an override, or upstream as a PR).
