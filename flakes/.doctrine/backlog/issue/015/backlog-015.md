# ISS-015: llm-gateway issue --out under sudo leaves the key file root-owned

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`llm-gateway` runs its store operations through sudo itself. Run as
`sudo llm-gateway issue … --out FILE`, the `--out` write happens as root, so
FILE is `root:root 0600` and the jail's wrapper reports the key as "missing,
empty or unreadable". Fix: chown to the invoking user.

Options: refuse to run as root (pointing out that it sudos internally), or
write `--out` as `$SUDO_USER`. Seen in SL-013 PHASE-06 (2026-10-17).
