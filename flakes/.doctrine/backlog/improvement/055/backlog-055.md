# malebolge-room unit loads screwtape's Jev credential

malebolge SL-007 / DEC-059 (operator, 2026-10-29): add to
`systemd.user.services.malebolge-room.Service` in
`features/satan/malebolge.nix`:

    LoadCredentialEncrypted = "jev:%h/.config/credstore.encrypted/screwtape.jev";

systemd decrypts it host-side into the unit's private `$CREDENTIALS_DIRECTORY`;
satan's launcher binds that directory read-only into the room jail (satan
IMP-060). No new key, no user bus in the jail. Pairs with satan IMP-060.
