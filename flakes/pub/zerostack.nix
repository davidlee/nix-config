{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  perl,
}:
rustPlatform.buildRustPackage rec {
  pname = "zerostack";
  version = "1.1.0-unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "gi-dellav";
    repo = "zerostack";
    rev = "b797e9a76d939c31e3701889c6abe461bc540396";
    hash = "sha256-gr65mYtRPyK5GFJVyMmerNgDWGelS/UgPwnr7krPLMI=";
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
