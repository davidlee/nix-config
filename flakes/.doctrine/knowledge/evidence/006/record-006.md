# UTM QEMU-backend test on Draupnir (2026-11-08)

Answers part of QUE-004 (the backend). Tested by agent and user together.

## Setup

- Draupnir: M2 Pro, 32 GB, 10 cores, macOS 27.0.1, UTM 5.0.8 (brew cask,
  now declared in `modules/darwin/brew.nix`).
- VM `nixos-qemu`: QEMU backend, hypervisor on, UEFI, 12 GB RAM, 6 cores,
  64 GB qcow2, display `virtio-gpu-gl-pci`, shared networking (guest
  192.168.64.2).
- Guest: stock NixOS minimal aarch64 ISO (26.11pre, unstable), then
  `nixos-install` of the throwaway config below (not the flake). niri via
  greetd autologin.

## Observed

| check | result |
|---|---|
| renderer | **virgl** for OpenGL ES on the gbm, wayland and surfaceless platforms (`eglinfo -B -p …`); niri renders on `/dev/dri/renderD128`. llvmpipe appears only for the desktop-GL profile |
| display | defaults to 1280x800 (blurry on Retina). UTM "native resolution" on, plus `niri msg output Virtual-1 custom-mode 3024x1964@60` and `scale 2`: user judged it "pretty good" (1:1, full screen on the built-in display) |
| dynamic resize | no: the preferred mode stays 1280x800. Only `spice-vdagentd` (system) runs; the per-session `spice-vdagent` does not start under niri |
| clipboard | not tested; same agent, so expected not to work under Wayland (inference) |
| shared folder | not tested (no host folder configured) |
| GL errors | one `GL_INVALID_VALUE in glTexSubImage2D` in the niri log |
| install footprint | 5.9 GB on disk |

## Not tested

The Apple backend (the next step), multiple displays, clipboard, virtiofs
or 9p shares, nested virtualisation (needs M3+).

## Pitfalls hit

- UTM crashes opening a VM window while the Mac's display is asleep
  ("invalid display count (0)"). `caffeinate -i` keeps the system awake but
  not the display.
- Draupnir's network is slow (~1 MB/s) and dropped once; resume downloads
  with `curl -C -`.
- `nixos-generate-config` without `--no-filesystems` conflicts with
  by-label `fileSystems`; run `udevadm settle` after `mkfs` before mounting
  by label.

## Throwaway guest config

Kept on Draupnir at `~/vm/nixos-test/` with the scripts (not in git).

```nix
# Throwaway guest for the UTM backend test (QUE-004). Not part of ~/flakes.
{pkgs, ...}: {
  imports = [./hardware-configuration.nix];

  # The fallback path (BOOTAA64.EFI) boots under either backend, no NVRAM entry.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.availableKernelModules = ["virtio_pci" "virtio_blk" "virtio_net" "virtio_gpu"];
  fileSystems."/" = {device = "/dev/disk/by-label/nixos"; fsType = "ext4";};
  fileSystems."/boot" = {device = "/dev/disk/by-label/boot"; fsType = "vfat";};
  # UTM shares: QEMU "VirtFS" is 9p, Apple's is virtiofs; both tagged "share".
  fileSystems."/mnt/share-9p" = {device = "share"; fsType = "9p"; options = ["trans=virtio" "version=9p2000.L" "nofail" "x-systemd.automount"];};
  fileSystems."/mnt/share" = {device = "share"; fsType = "virtiofs"; options = ["nofail" "x-systemd.automount"];};

  networking.hostName = "nixos-test";
  nix.settings.experimental-features = ["nix-command" "flakes"];

  users.users.david = {
    isNormalUser = true;
    extraGroups = ["wheel" "video"];
    initialPassword = "test";
    openssh.authorizedKeys.keys = ["ssh-ed25519 <key>"];
  };
  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;

  programs.niri.enable = true;
  hardware.graphics.enable = true;
  services.greetd = {
    enable = true;
    settings.initial_session = {user = "david"; command = "niri-session";};
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
  };
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  environment.systemPackages = with pkgs; [foot fuzzel firefox mesa-demos pciutils wl-clipboard];

  system.stateVersion = "26.05";
}
```
