
def gateway-key []: nothing -> string {
  open --raw ~/.config/llm-gateway/keys/pi | str trim
}

# pi on the gateway.
export def --wrapped ppi [...args] {
  with-env {LLM_GATEWAY_KEY: (gateway-key)} {
    pi ...$args
  }
}

# o> ~/.pi/models.json
export def models [] {
  cd ~/flakes
  nix eval --json --impure --expr '
    let g = import ./agents/gateway.nix; lib = (builtins.getFlake "nixpkgs").lib;
    in import ./agents/pi-gateway.nix {inherit lib;} g.url g.models'
}

# Thin bwrap jail (IDE-009). Not a project jail: host toolset, cwd rw, the
# rest of $HOME ro, secrets hidden. Rules out the worst outcomes, no more.

# $HOME-relative; dirs become empty tmpfs, files an unreadable /dev/null (nodev).
const HIDDEN = [
  .ssh .gnupg .config/op .config/llm-gateway .config/gh/hosts.yml
  .local/share/keyrings .local/share/atuin
  .npmrc .cargo/credentials.toml .netrc .git-credentials .aws
]

# Rw config dir of the jailed agent.
const AGENT_DIR = ".pi/agent"

def conceal [path: path]: nothing -> list<string> {
  match ($path | path type) {
    dir => [--tmpfs $path]
    file => [--ro-bind /dev/null $path]
    _ => []
  }
}

# Opt-in exposure, after the hides so a bind can land inside a hidden dir.
def expose [flag: string, home: path]: nothing -> list<string> {
  match $flag {
    ssh => ([
      [--bind $env.SSH_AUTH_SOCK $env.SSH_AUTH_SOCK]
      ...([config known_hosts] | each {|f| $home | path join .ssh $f }
        | where ($it | path exists) | each { [--ro-bind $in $in] })
    ] | flatten)
    cfg => [--bind ($home | path join .cfg) ($home | path join .cfg)]
    _ => (error make {msg: $"jail: unknown --with flag '($flag)'; known: ssh, cfg"})
  }
}

def jail-args [cwd: path, home: path, uid: int, with: list<string>]: nothing -> list<string> {
  let agent_dir = $home | path join $AGENT_DIR
  # Without cfg, git must not discover the home repo from a subdir of ~.
  let ceiling = if "cfg" in $with { [] } else { [--setenv GIT_CEILING_DIRECTORIES $home] }
  [
    [--ro-bind / / --dev /dev --proc /proc --tmpfs /tmp]
    # allowlist: nothing from the runtime dir (bus, systemd, gnupg, op, emacs, docker …)
    [--tmpfs $"/run/user/($uid)" --tmpfs /run/dbus]
    ($HIDDEN | each {|p| conceal ($home | path join $p) } | flatten)
    ($with | each { expose $in $home } | flatten)
    [--bind $cwd $cwd --bind $agent_dir $agent_dir --chdir $cwd]
    [--unshare-user --unshare-pid --unshare-ipc --unshare-uts --unshare-cgroup-try --die-with-parent]
    # cwd is a bind mount; git otherwise stops discovery at it.
    [--setenv PI_CODING_AGENT_DIR $agent_dir --setenv GIT_DISCOVERY_ACROSS_FILESYSTEM 1]
    $ceiling
    [--unsetenv DBUS_SESSION_BUS_ADDRESS --unsetenv DISPLAY --unsetenv WAYLAND_DISPLAY]
    (if "ssh" in $with { [] } else { [--unsetenv SSH_AUTH_SOCK] })
  ] | flatten
}

# Run a command in the jail, scoped to cwd. --with: comma list of ssh, cfg.
export def --wrapped jail [--with: string = "", cmd: string, ...args] {
  let home = $env.HOME | path expand
  let cwd = $env.PWD | path expand
  if ($home | str starts-with $cwd) {
    error make {msg: $"jail: cwd ($cwd) contains $HOME; run it from a project dir"}
  }
  let with = $with | split row "," | str trim | where $it != ""
  ^bwrap ...(jail-args $cwd $home (id -u | into int) $with) -- $cmd ...$args
}

# pi in the jail, on the gateway.
export def --wrapped pox [--with: string = "", ...args] {
  with-env {LLM_GATEWAY_KEY: (gateway-key)} {
    jail --with $with pi ...$args
  }
}
