# IMP-064: Uniform quotient forms: replace per-repo bespoke form families with dev-envs forms

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

From the IMP-060 migration (2026-11-04). Every project flake except www still
carries its own `jailLib.quotientFormFamily` and `quotient-read` /
`quotient-write` outputs, plus a `just quotient-forms` recipe or devshell
command to link them. The dev-envs consumer builds the same forms from the
project's `dev-tools` (`bin/dev-envs-forms` links them). Two definitions per
repo means the forms can drift from the jails, and each repo restates the
toolset.

Target: one definition. A repo's forms come from `dev-envs`; its
`quotientFormFamily`, `quotientForms` outputs, link recipe and `quotient`
flake input go, and its `.envrc` enters through `use_dev_envs`.

State per repo (flake still defines a family / `.envrc` on dev-envs):

| repo | own family | `use_dev_envs` | forms linked from |
|---|---|---|---|
| panopticon | yes | no | own |
| deck_of_dwarf | yes | no | own |
| malebolge | yes | no | own |
| smut | yes | yes | own |
| screwtape | yes | yes | own |
| org-incremental-writing | yes | yes | own |
| satan | yes | yes | own |
| satan-attrd | yes | yes | own |
| sediment | yes | yes | dev-envs |
| zmux | yes | no | dev-envs |
| www | no | yes | dev-envs |

Per repo: re-link with `dev-envs-forms`, `quotient allow` (the operator's act),
delete the family and its recipe, confirm the form's tools and env match (a
family may carry extras the project's `dev-tools` lacks: org-incremental-writing's
`/usr/bin/env` bind and `ORG_IW_DENOTE_DIR`, panopticon's collisions), then
commit. Compare each family against the consumer's before deleting it.

Open: whether the consumer should accept form-only extras (a family option such
as org-iw's `/usr/bin/env` bind) or the project's `dev-tools` should absorb
them. Satan's forms wait for IMP-062's mounts only if its family has any.

Related: IMP-060, IMP-062, SL-022.

Carried over from IMP-060: panopticon, deck_of_dwarf and zmux also still need
their `.envrc` moved to `use_dev_envs` (panopticon and zmux already export
`dev-tools`; deck_of_dwarf does not and needs one).
