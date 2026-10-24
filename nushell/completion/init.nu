#!/usr/bin/env nu

#
# completions
#

$env.CARAPACE_BRIDGES = 'fish,zsh,bash'

# `place.command`: tokens of the command under the cursor (also after a pipe or `;`).
let carapace_completer = {|place|
  CARAPACE_LENIENT=1 carapace $place.command.0 nushell ...$place.command | from json
}

$env.config.completions.external = {
  enable: true
  max_results: 100
  completer: $carapace_completer
}

source ./zmx-completions.nu
source ./just.nu
