# IMP-018: Podman replaces docker; docker off but coverage-checked

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Podman becomes the only container engine on Sleipnir; rootless docker is
deselected but kept evaluating.

State after SL-005 (DEC-022): `virt.docker` selected (workstation profile),
`virt.podman` an unselected feature with a `Sleipnir+podman` coverage target,
and the two exclusive by assertion in the docker feature. So this item is a
selection change:

- Sleipnir selects `virt.podman` and sets `virt.docker` false; the coverage
  target flips to `Sleipnir+docker`.
- Move lazydocker and similar docker-only tools out (or keep them in the off
  docker feature).
- Decide on `virtualisation.podman.dockerSocket.enable` for tools that expect
  a docker socket.
- `setSocketVariable` exports `DOCKER_HOST` for the rootless daemon; projects
  that run supabase need their `.envrc` updated when it goes.
- Keep the no-rootful-docker assertion (`modules/nixos/security.nix`).
- Podman's old storage (`~/.local/share/containers`) is still on disk; prune
  what is not wanted before or after the swap.
