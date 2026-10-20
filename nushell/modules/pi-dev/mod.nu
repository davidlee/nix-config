
export def pi-dev [...args] {
  with-env {LLM_GATEWAY_KEY: (cat ~/.config/llm-gateway/keys/pi) } {
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
