# Read-only git for a project whose repository sits above it: its worktree is the
# project's parent, and the git dir a sibling of the project (the home repo's
# `~/.cfg`, worktree `$HOME`, project `~/flakes`). Everything outside the project
# reads as deleted, so a write here would be dangerous: `commit -a` would record
# them all. Hence read-only, which also settles planted hooks and config.
#
# `outerGit c { gitDir; parent; }`, for `extraOptions` or a form's `options`:
#   gitDir  the git dir's name, a sibling of the launch directory
#   parent  where the project's parent is mounted, a shell word expanded inside
#           double quotes: "/workspace" in a jail, "$HOME" in a form
#
# A runtime block, so it follows every static bind. It applies only to a launch
# from the project root: elsewhere the launch dir mounts at the wrong depth, and
# no repo beats a repo whose paths are all wrong.
{pkgs}: let
  # Relative, so one file serves any parent, and without the host's remotes.
  config = pkgs.writeText "outer-git-config" ''
    [core]
    	repositoryformatversion = 0
    	filemode = true
    	bare = false
    	worktree = ..
    [status]
    	showUntrackedFiles = no
  '';
in
  c: {
    gitDir,
    parent,
  }:
  # The gitfile is bwrap's, by --ro-bind-data, not a store file: git refuses a
  # gitfile it does not own ("dubious ownership"), and in a jail the store's
  # owner is nobody. The bind is a mount boundary, hence the discovery flag.
    c.add-runtime ''
      if [ "''${PWD%/*}" = "$HOME" ]; then
        exec {outer_gitfile}<<<'gitdir: ${gitDir}'
        RUNTIME_ARGS+=(
          --ro-bind "$HOME/${gitDir}" "${parent}/${gitDir}"
          --ro-bind ${config} "${parent}/${gitDir}/config"
          --ro-bind-data "$outer_gitfile" "${parent}/.git"
          --setenv GIT_DISCOVERY_ACROSS_FILESYSTEM 1
        )
      fi
    ''
