
const ghostel_nu = "~/.config/emacs/elpa/ghostel/etc/shell/ghostel.nu"
const conditionally = if ($ghostel_nu | path exists) { $ghostel_nu } else { null }
source $conditionally
