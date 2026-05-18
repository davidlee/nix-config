{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  perl,
}:
rustPlatform.buildRustPackage rec {
  pname = "zerostack";
  version = "1.1.0-unstable-2026-05-18";

  src = fetchFromGitHub {
    owner = "gi-dellav";
    repo = "zerostack";
    rev = "69a4cb0c20f3b2598d65210adf882f119baffd70";
    hash = "sha256-ncaDJS8MiI316H7GgFc3CP3QMsyALpNUsJihE8oggDA=";
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
