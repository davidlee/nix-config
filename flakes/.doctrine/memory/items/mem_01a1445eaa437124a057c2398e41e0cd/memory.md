Seen in SL-009 (RV-019, 2026-10-16). After disposing a major finding with
`doctrine review dispose … --disposition fix-now` (no `--route`) and
verifying it, recording `review-disposed` succeeded but the run then
reported "severe findings carry no route: F-1" and the reviewing→locked edge
stayed blocked.

Fix: `review reopen --finding F-n --note …` (raiser), `review dispose …
--route review` (responder), `review verify`, `review conclude --basis …`,
then re-record `review-disposed`. Cheaper: pass `--route` when first
disposing any major/blocker finding. `review conclude` requires `--basis`.
