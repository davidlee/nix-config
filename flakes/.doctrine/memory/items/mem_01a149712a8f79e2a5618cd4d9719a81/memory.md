Observed 2026-10-17 (SL-013, run rev 47). A `doctrine design apply` submission in stage `reviewing` that declared adversarial section attestations (`att-*` with `reviewer: adversarial`) together with a top-level `"acceptance": {"basis": …}` also logged `act_recorded cpa-design-accepted act=design-accepted`, an act the user had not given.

- There is no verb to retract it, and recording `review-disposed` afterwards did not make it stale (it stayed `current: true`).
- It was replaced only by the real acceptance at lock (`act_invalidated` then `act_recorded`).

**How to apply:** when recording the adversarial lane's attestations, check whether the payload needs a top-level `acceptance`. If it does, word the basis as the agent's account and check `doctrine design show <slice> --format json` → `acts` right after the apply. Never let it stand as the user's acceptance: tell the user, and do not lock until they accept explicitly.
