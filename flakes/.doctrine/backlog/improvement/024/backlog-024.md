# IMP-024: Enable the panopticon-digest daily timer

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Raised 2026-10-16 (from satan IMP-035, which exposes digests to SATAN's
`content_read`).

`panopticon-digest` (panopticon SL-006..008) is the opt-in daily batch job
that writes `~/.local/state/behaviour/digest/<sha[:2]>/<sha>.digest.json`.
It has never been wired as a unit here: `modules/home/linux/behaviour.nix`
declares `panopticon-git` and `panopticon-segmentize` services/timers only.
The ~1442 digests on disk came from manual runs ending 2026-10-02, so no
capture since then has a summary.

## Shape

Mirror `panopticon-segmentize` in `behaviour.nix`:

- service `panopticon-digest`: `ExecStart = "${panopticon}/bin/panopticon-digest"`,
  `EnvironmentFile = ~/.config/panopticon/digest.env` (holds
  `OPENROUTER_API_KEY`; panopticon README "To run it daily" — systemd cannot
  honour `XDG_CONFIG_HOME` for it).
- timer: daily, wall-clock `OnCalendar` + `Persistent=true` (the
  `OnUnitActiveSec` stranding noted on the panopticon-git timer applies).
- Upstream ships `systemd/digest.{service,timer}` in the panopticon repo;
  read those first and keep their hardening.

## Open

- Key provisioning: `digest.env` by hand (as README) vs 1Password/sops. It
  must not land in the store.
- Config `~/.config/panopticon/digest.toml` (model, endpoint, denylist)
  exists by hand; `digest.env` does not (checked 2026-10-16). Should
  home-manager own the toml? Unknown keys are an error.
- Cost / volume: first run digests the whole backlog since 2026-10-02;
  consider `--limit` for that run.
