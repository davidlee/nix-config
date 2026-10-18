# CHR-020: Author a tech spec for the agents jail library

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`agents/` is a published sub-flake (~730 lines of `jailed-agents.nix`, plus
tests and the template) that about nine `~/dev` flakes depend on (IDE-008),
several still through the deprecated `flakes/pub` shim. Its contract lives
in `agents/README.md` and decisions DEC-049, DEC-058, DEC-059, DEC-061,
DEC-062, DEC-063 and DEC-066.

A container tech spec, written like SPEC-001 with the consumer contract
first:

- the consumer contract: `makeJailedAgent` arguments, what a jail may see
  (binds, environment, FD key path), `gatewayClient`, the template;
- gateway mode as SPEC-001's client side (cite it, don't restate it);
- the perimeter: bubblewrap, git guard, what persists;
- stability: what a consumer lock pins, and how breaking changes reach
  consumers (the `flakes/pub` shim retirement).

Settles from the jail side what IDE-008 asks: what `agents/` owns when the
gateway leaves, and whether oubliette's light tier (its Plan B) builds on
it. Related: IMP-036 (jail tests), IMP-034, IMP-030, IDE-004.
