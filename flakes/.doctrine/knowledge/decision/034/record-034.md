# DEC-034: Home verification: an aarch64-linux home base target and a committed local-input isolation check

<!-- Knowledge record body — context, detail, links. The structured, queried
     fields live in the sister `record-NNN.toml`; this prose is free-form and is
     never structurally parsed (the storage rule). -->

Amended 2026-10-18 (user: "DEC-034 yes amend"), after the GPT review of SPEC-002: the choice claimed the stub makes "any reference" fail, but an empty-output stub still has an outPath, so only uses of the inputs' outputs fail. The choice no longer copies the dev-checkout list (it named oubliette; the list now has fleet) and points at bin/dev-checkouts instead.