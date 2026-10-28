# CHR-026: treefmt check red on _templates/rust/shell.nix after the formatter update

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`doctrine check gate` fails in `checks.treefmt` on `_templates/rust/shell.nix`
alone: the formatter now lays out the `{pkgs ? import <nixpkgs> {…}}:` argument
differently. The file is unchanged since d6fcaf2e (2025-10-20); the formatter
most likely moved with the flake.lock bump in 504ebca5. `just test` is green.

Fix: run treefmt on the file and commit it. Found by the SL-019 audit (RV-042 F-8).
