`doctrine knowledge edit decision --consequences` (and `--alternatives`)
replaces the whole list and splits its argument on every comma. No escape
exists, so an existing item that contains a comma ("a probe, not proof") is
split into two items if you pass it back through the flag.

Before replacing a list, read the current array from the record's TOML
(`.doctrine/knowledge/<kind>/NNN/record-NNN.toml`) and check its items for
commas. If any item has one, either reword that item (comma → semicolon) or
edit the TOML array directly, then run `doctrine validate`.

Note: neither the CLI nor a direct edit bumps `updated` on decision records.

Found reconciling SL-009 (RV-021): DEC-018 was edited in TOML; DEC-034's
consequence was reworded.
