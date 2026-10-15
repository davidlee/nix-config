Survey done by grep over modules/ and darwin/ during the feature-architecture
preflight. Treatment of each coupling under ADR-001..005 is recorded in the
local review packet (review.features.local.md, v2) and the backlog.

Unverified at capture: which module declares
`services.displayManager.noctalia-greeter` (nixpkgs vs the umbriel flake
module). If umbriel, the greeter has a hidden dependency on umbriel.
