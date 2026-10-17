# IMP-028: Migrate jailed pi to the credential broker; remove auth.json provider key

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Fast follow to SL-011, which migrates eca only (user, 2026-10-17: "eca first
to keep it easy but it doesn't solve much. pi does, so a fast follow").

pi is the harness in daily use, across project flakes built from
`_templates/agents`. Work:

- broker mode for `makeJailedPi` in the `agents` sub-flake (opt-in, off by
  default: the sub-flake is published);
- a pi `models.json` provider pointed at the broker's loopback relay, with
  `apiKey` as `!command` reading the per-jail key file bound read-only;
- the template and at least one project flake;
- **remove the stored `deepseek` key from the shared
  `~/.local/share/jail.nix/home/agent/.pi/agent/auth.json`**: it sits inside
  every specDev pi jail and beats any injected key (SL-011 research C4, C5).
  Rotate it afterwards (POL-001 rule 6, IDE-005).

The OAuth subscription logins in the same auth.json (openai-codex,
gemini-cli, antigravity) cannot go through an API-key broker and stay.
