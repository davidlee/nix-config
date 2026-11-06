To see what a fleet target's tool set holds at fleet's lock, evaluate
`(builtins.getFlake "git+file:///srv/fleet").inputs.<target>.packages.<system>.<output>.drvPath`
with `nix eval --impure`, then grep `nix-store -q --requisites <drv>` for the tool.
A path ref, or `/srv/fleet` bare, fails with "file '/srv/fleet/.vm/capsule/capsule.sock'
has an unsupported type". git+file sees tracked files, the working tree's edits included.
Read closures rather than flake.nix: a grep missed emacs-config's Doctrine until read,
and a flake's own HEAD can differ from what fleet locks (screwtape's dev-tools).
Adding `inputs.doctrine.follows` to a fleet input shrinks flake.lock by hundreds of
lines; check that only the intended root inputs moved, not the diff size.