Measured 2026-11-02 (SL-022 PHASE-03 follow-up).

Neither zsh nor bash expands `~` mid-word:

    $ zsh -c 'echo path:~/flakes/dev-envs#jail'
    path:~/flakes/dev-envs#jail

so nix resolves the tilde literally and fails:

    error: getting status of '/tmp/~/flakes/dev-envs': No such file or directory

Write the ref quoted instead — the form `envrc/dev-envs.sh` already uses — and
both hazards disappear (`$HOME` expands; `#` inside quotes is literal in zsh,
bash, fish and nushell):

    nix develop "path:$HOME/flakes/dev-envs#jail" \
      --override-input project "git+file:$(git rev-parse --show-toplevel)" \
      --no-write-lock-file

Same for `git+file:~/dev/smut`: it must be an absolute path (substitute
`$HOME`) or the shell-derived toplevel.


## Correction, same day: an unquoted `#` is a second, independent hazard

The first version of this note said the `#` needed no escaping, because
`zsh -c 'echo a#b'` printed it fine. That test was invalid: `zsh -c` is
non-interactive and never reads `~/.zshrc`. This shell's interactive config sets
`extendedglob` (`setopt` confirms it), so an unquoted `#` is the repetition
operator and the word becomes a pattern:

    $ zsh -i -c 'echo a#b'
    zsh:1: no matches found: a#b

Not a comment — a glob — but the command never runs either way. Interactive
`bash -i -c 'echo a#b'` is fine, so the hazard is config-specific, and it bites
exactly the flake refs this repo writes (`…-dev-envs#jail`, `…#checks.${sys}.stub`).

Quoting fixes both hazards at once, and only quoting does:

    zsh -i -c 'echo "path:$HOME/flakes/dev-envs#jail"'     # literal, as intended
    zsh -i -c 'echo path:/home/david/flakes/dev-envs\#jail'  # works too

Verify shell-quoting claims with the real shell (`zsh -i`), never `sh -c`.