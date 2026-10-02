#!/usr/bin/env nu

#
# completions
#

$env.CARAPACE_BRIDGES = 'fish,zsh,bash'

let carapace_completer = {|spans|
    # Invoke carapace for nushell and parse the JSON output
    CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}

$env.config.completions.external = {
  enable: true
  max_results: 100
  completer: $carapace_completer
}

source ./zmx-completions.nu
