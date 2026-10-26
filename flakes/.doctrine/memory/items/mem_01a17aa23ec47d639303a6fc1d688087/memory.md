A launcher built by jail.nix (`makeJailedAgent` in `agents/jailed-agents.nix`)
emits the entire `exec …/bwrap …` invocation as a single line of the script.
Every bind, `--chdir`, `--setenv` and `--args` sits on that line.

So a test that asserts mount order (bwrap applies mounts in argv order) cannot
compare `grep -n` line numbers: both matches return the same line and `-lt`
fails silently under errexit. Compare byte offsets instead:

    a="$(grep -boF -- '/workspace/normal' "$launcher" | head -1 | cut -d: -f1)"
    b="$(grep -boF -- '--bind "$PWD"' "$launcher" | head -1 | cut -d: -f1)"
    test "$a" -lt "$b"

Example: SL-018's launch-dir-last check in `agents/jailed-agents-test.nix`.
