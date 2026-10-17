Observed SL-011, 2026-10-17 (doctrine design run at stage reviewing).

`checkpoint_act {act: "section-reviewed", ...}` is refused: "its rule binds to `per-section` coverage and the act carries none". The CheckpointActDeclaration has no section field.

What clears `section-attestations-current`: declare one attestation per section, no checkpoint_act:

    {"declare":[{"subject":"att-1","attests":"sec-1","reviewer":"human"}, ...]}

Attestations carry no basis field; cite the user's assent in the `review-disposed` and `design-accepted` acts' acceptance basis. Then `review-disposed` (conducted) can still fail on unrouted severe findings — see the route memory (Design review-disposed needs a route on major findings).
