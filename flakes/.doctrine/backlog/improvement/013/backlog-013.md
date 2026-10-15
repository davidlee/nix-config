# IMP-013: Resolver walks the feature tree once

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`features.nix` walks `tree` three times: `records`, `badShapes`, and
`options.feature` (built per area from `area.value`). `options.feature` could
be built from `records` (`setAttrByPath [area name "enable"]`), leaving one
walk of the shape plus the guard. Raised by the RV-008 code review (SL-003
audit pass 2); outside SL-003's scope. Behaviour unchanged; `just drvs` must
stay identical.
