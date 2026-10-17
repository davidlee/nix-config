# IDE-006: Full-disk encryption (LUKS) on Sleipnir

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Sleipnir's disks are unencrypted (2026-10-17, `lsblk`: nvme0n1p2 is plain
ext4 holding `/` and `/nix/store`; sda and sdb are plain ext4 too). Anything
at rest — `/var/lib`, `~`, persisted jail homes with agent transcripts
(IDE-005) — is readable from a pulled disk or an image.

The machine has a working TPM2 (`/dev/tpm0`, `systemd-analyze has-tpm2`:
yes), so LUKS2 with TPM2 unlock (`systemd-cryptenroll --tpm2-device=auto`)
plus a recovery key would avoid a boot passphrase.

Raised during SL-011 design (inq-3): the broker's provider keys are encrypted
with `systemd-creds` against the TPM because the disk is not. LUKS would
cover everything else.

Cost: a reinstall or an in-place `cryptsetup reencrypt` of the root
partition, with a full backup first.

Evidence (RV-026 F-12, SL-011 VH-2, 2026-10-17): `systemd-creds encrypt`
warned "Credential secret file '/var/lib/systemd/credential.secret' is not
located on encrypted media, using anyway." The gateway's provider credential
is bound to host+TPM2; the TPM2 half still ties it to this machine, but the
host half is readable from the disk. LUKS would protect that half too.
