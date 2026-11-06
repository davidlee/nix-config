# STD-001: Templates teach the current way

## Statement

`_templates/` teaches the current way. When the right way to do something it
covers changes, the same change updates the template.

1. A template is a working example: `nix flake init` gives a project that runs.
2. Comments explain what a reader must know to adapt it: what goes where, why,
   and what must stay out. A rule that needs code only some projects want is a
   commented example.
3. A template does not teach a retired pattern, even for projects not yet
   migrated. Migration notes live in the backlog.

**Note:** A standard with status "default" is recommended unless there is
justification to deviate; `required` mandates it.

## Rationale

New projects copy the template, so a stale one spreads the old way. By
2026-11-06 `_templates/agents` still taught per-repo jails, retired by SPEC-003,
and agents had to learn the right way from migrated repos and handovers (IMP-069).

## Scope

Applies to: every template under `_templates/`, and every change to a decision,
spec or mechanism that a template's code or comments depend on. For
`_templates/dev-env`, that means SPEC-003, `dev-envs/`, `envrc/dev-envs.sh` and
`bin/dev-envs-forms`.

Excludes: a one-off practice in a single project, until it is the right way for
all of them.

## Verification

- `checks.<system>.templates` (`templates-test.nix`, in `just test`): each
  template evaluates, and `dev-env` meets the producer contract. A change to the
  contract that the template does not follow fails here.
- Review: a change to what a template teaches shows the template in its diff.
  Comments have no test.

## References

- SPEC-003: the dev-environment contract `_templates/dev-env` teaches.
- DEC-128, DEC-129: where Doctrine goes; which templates exist.
- IMP-069: the audit that raised this.
