{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  perl,
}:
rustPlatform.buildRustPackage rec {
  pname = "zerostack";
  version = "1.1.0-unstable-2026-06-02";

  src = fetchFromGitHub {
    owner = "gi-dellav";
    repo = "zerostack";
    rev = "f0cc5fc0f2a0716b1e8881dc86ae65fc89085ff5";
    hash = "sha256-+TIJTxaiqPUaY3bq/JZDdpMkmpg1YiB+Dr2DL+Vc/Fk=";
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
