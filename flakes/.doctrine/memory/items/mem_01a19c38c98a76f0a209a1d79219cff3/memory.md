Learned building SL-022's design (2026-11-02), each by being refused:

- **Sections render in the run's stored order, not numerically.** Ten sections
  declared 1..10 materialised as 1,2,3,4,5,10,6,7,8,9 and stayed that way across
  re-materialisations. Re-declaring a body keeps its slot. So assign *content* to
  the ids you already have rather than expecting numeric order — `sec-10` can
  legitimately be the sixth section in the document.
- **A section cannot be deleted.** `{"subject":"sec-7","body":null}` is refused
  with "section sec-7 was declared without a body". There is no prune verb. A
  merged section therefore leaves its id holding whatever you put there.
- **A checkpoint must both dispose an inquiry and create a record**: declaring
  `cp-8` with `dispose.create` and no `disposes` is refused ("needs both the
  inquiry it disposes and the record that disposes it"). To supersede a decision
  you already recorded, reopen its inquiry (`lifecycle: "open"`), dispose it again
  with the revised record, then `doctrine supersede NEW OLD`.
- **A kind's fields go under `facet`, not beside `kind`.** `dispose.create` with a
  `decision = {…}` key is refused; `facet = {context, choice, alternatives,
  rationale, consequences, decided_by, decided_on}` is accepted (and the same
  `facet` shape carries every other RecordKind's fields).
- `doctrine design materialise` before every `drafting → reviewing`/advance: the
  run compares `design.md`'s digest against what it last wrote.
