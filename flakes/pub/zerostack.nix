{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  perl,
}:
rustPlatform.buildRustPackage rec {
  pname = "zerostack";
  version = "1.1.0-unstable-2026-06-01";

  src = fetchFromGitHub {
    owner = "gi-dellav";
    repo = "zerostack";
    rev = "88d001238936c879ffd3b9a6934c4a6ce7bbbed6";
    hash = "sha256-9068StNCZN/G2rlZfbiDpkVmwqPbBoharhlxs0gxGvc=";
  };

  cargoLock.lockFile = src + "/Cargo.lock";

  nativeBuildInputs = [
    cmake
    perl
    rustPlatform.bindgenHook
  ];

  # Default features (loop, git-worktree, mcp) — no override needed.

  meta = {
    description = "Minimalistic coding agent written in Rust";
    homepage = "https://github.com/gi-dellav/zerostack";
    license = lib.licenses.gpl3Only;
    mainProgram = "zerostack";
  };
}
