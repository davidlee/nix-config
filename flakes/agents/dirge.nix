{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  perl,
}:
rustPlatform.buildRustPackage rec {
  pname = "dirge-agent";
  version = "0.7.7";

  src = fetchFromGitHub {
    owner = "dirge-code";
    repo = "dirge";
    rev = "v${version}";
    hash = "sha256-H82uiruToka8Itu99d1Pc1srcLYgO0TNLA52gIcWWbA=";
  };

  cargoLock.lockFile = src + "/Cargo.lock";

  # Upstream pins clang+mold on Linux purely for faster incremental dev
  # links (their own comment: "the user can comment them out"). Neither is
  # in the build sandbox, so drop the override and use the stdenv linker.
  postPatch = ''
    substituteInPlace .cargo/config.toml \
      --replace-fail 'linker = "clang"' "" \
      --replace-fail 'rustflags = ["-C", "link-arg=-fuse-ld=mold"]' ""
  '';

  # Upstream's test suite couples to a live git repo and provider APIs
  # (find_git_root_in_this_repo, git_worktree merges, provider::client) —
  # ~37 of 2771 fail in the network-/repo-less build sandbox. Binary only.
  doCheck = false;

  # Default features build only the `dirge` binary; `dirge-microvm-runner`
  # sits behind the opt-in `sandbox-microvm` feature (libkrun) and is skipped.
  nativeBuildInputs = [
    cmake # aws-lc-sys
    perl # ring / aws-lc-sys
    rustPlatform.bindgenHook # evil-janet + aws-lc-sys bindgen → libclang
  ];

  meta = {
    description = "Minimalistic coding agent written in Rust, optimized for memory footprint and performance";
    homepage = "https://github.com/dirge-code/dirge";
    license = lib.licenses.gpl3Only;
    mainProgram = "dirge";
  };
}
