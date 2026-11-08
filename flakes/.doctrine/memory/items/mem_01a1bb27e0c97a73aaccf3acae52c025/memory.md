UTM 5.0.8 on Draupnir, driven over ssh with `osascript` (observed 2026-11-08, EVD-006).

- `make new virtual machine with properties {backend:qemu, configuration:{…}}`
  creates a VM; display card, drives, memory and network all settable.
  The dictionary is at `/Applications/UTM.app/Contents/Resources/UTM.sdef`
  (`sdef` itself needs full Xcode).
- `input keystroke` and `input mouse click` work on the QEMU backend only:
  the way to type an SSH key into a stock installer's console.
- The first `osascript` from ssh pops macOS automation-permission dialogs on
  the Mac's screen; the user must approve them.
- `start` hangs (AppleEvent timeout) and UTM crashes ("invalid display count
  (0)") if the Mac's display is asleep. `caffeinate -i` does not wake it;
  `caffeinate -u` does.
- Records from `configuration of vm` are copies: edit a field, assign the
  list back (`set displays of cfg to {d}`), then `update configuration`, with
  the VM stopped. Iterating `drives of cfg` by reference fails (-1728).
- Shared-mode guests sit on 192.168.64.0/24 (host .1); no DHCP lease file is
  written and the NixOS installer drops pings. Have the guest report itself:
  `ip -br a > /dev/tcp/192.168.64.1/<port>` against `nc -l` on the host.
- Draupnir's login shell is nu: run remote commands as `ssh Draupnir bash -s`.
