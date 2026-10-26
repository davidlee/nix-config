# IMP-050: W8 — Bump llm-agents to the newest rev whose codex is cached

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W8. Codex comes from numtide's `llm-agents` (`agents/flake.nix`),
deliberately not following nixpkgs so `cache.numtide.com` applies. A bump
takes HEAD; when numtide has not cached that rev's codex yet, codex builds
from source (slow).

Want: a bump recipe that walks recent `llm-agents` revs newest-first (capped),
evaluates codex's store path at each, queries `cache.numtide.com` for its
narinfo, and locks the first cached rev; refuses if none. **Codex only** —
the only slow build among the agents in use (user, 2026-10-27).

Reuse: `workarounds/check` already queries narinfo, but only
cache.nixos.org; IMP-041 records that gap for non-nixpkgs inputs. Make the
query take a substituter rather than writing a second one.
