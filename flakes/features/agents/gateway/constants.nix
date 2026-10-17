# Where the gateway is reached. The address now lives in the published
# `agents` sub-flake (agents/gateway.nix), so out-of-tree jails read it too;
# this re-export keeps the NixOS record's imports where they were (REV-009).
import ../../../agents/gateway.nix
