Observed authoring SPEC-001 (2026-10-18, doctrine CLI as installed then):

- `doctrine spec` has no status verb. Status is the `status` line in
  `spec-NNN.toml`; doctrine's own corpus uses `active` (the scaffold seeds
  `draft`).
- `spec req add` takes only kind and title. The statement is `description`
  and the criteria are `acceptance_criteria` (list of strings), hand-edited
  into `.doctrine/requirement/NNN/requirement-NNN.toml`; `spec req show`
  renders them.
- A `c4_level = "container"` spec with no `parent` and no `descends_from`
  passes `doctrine spec validate`.
- List-valued flags (`knowledge edit decision --alternatives/--consequences`)
  split on commas: write items without inner commas (use semicolons).
- `doctrine link` with `references` refuses a DEC target; use
  `DEC-NNN spawns <item>` instead.
- New entities get slug symlinks beside the numeric dir; `git add` them
  explicitly (they are untracked).

House style set by SPEC-001: the consumer contract leads, then
Responsibilities, Mechanism, Concerns, Hypotheses, a decisions index table,
Open questions. Claims no stronger than the tests show; unverified behaviour
labelled as such.

Lesson from the SPEC-002 review (2026-10-18): before writing a check's
guarantee into a spec, state what its oracle can detect. Three overclaims
were caught: sorted package sets (`just drvs-sets`) cannot show a
collision winner; a `mkNixos` coverage target forces only the nixos half;
an empty-output stub flake (`features/stub`) still has `outPath`, so
isolation proves "no outputs used", not "never referenced". Also: copy a
list from its single source (`bin/dev-checkouts`), not from a decision
record: DEC-034 had named oubliette after the list replaced it with fleet (amended 2026-10-18).
