# IDE-007: last-good walks back to the last different rev of an input

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`workarounds/last-good <input>` prints the input's rev from the previous
committed lock. When the last lock change moved only other inputs, that equals
the current rev. Walk back to the last commit where this input's rev differed.
As designed for now (README states "previous lock"). SL-012 PHASE-03; RV-027 F-6.
