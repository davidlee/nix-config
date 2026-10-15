`security.sudo.extraRules` is last-match-wins, and the nixpkgs sudo module
(`nixos/modules/security/sudo.nix:252,257` in the pinned nixpkgs) adds
`root ALL` at `mkOrder 400` and `%wheel ALL` at `mkOrder 600`. A rule
defined at plain priority (1000) in any module therefore renders **after**
both, so a narrow NOPASSWD grant for a wheel member is not overridden by
the blanket rule, whatever the defining module's import depth.

Moving a plain-priority rule between modules can only reorder it relative
to other plain-priority rules (`mem.fact.nix.merge-order`). That is
harmless when their commands are disjoint. Only `mkAfter` rules (e.g.
oubliette's capsule-proxy restarts) are pinned last.

Check the rendered order with
`nix eval --raw .#nixosConfigurations.<h>.config.security.sudo.configFile`
(with `just --evaluate system_override`). Oubliette's
`host/services.nix:690` comment describes an older state in which wheel
landed after a plain rule.
