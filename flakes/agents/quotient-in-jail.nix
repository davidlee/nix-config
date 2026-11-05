# agents/quotient-in-jail.nix — the real quotient inside a jail.
#
# formStoreBinds is for every form, in a jail or not: what a form nested in a
# jail needs and cannot find for itself.
{
  lib,
  pkgs,
}: let
  # `etc-store-binds PATH...`: for each link under the paths, the store path it
  # resolves to, as NUL-separated bwrap words. A runtime arg, as the other
  # runtime binds are: quotient's check needs the form's bwrap line plain.
  etcStoreBinds = pkgs.writeShellScript "etc-store-binds" ''
    PATH=${lib.makeBinPath [pkgs.findutils pkgs.coreutils pkgs.gnused]}
    find "$@" -type l -exec readlink -f {} + 2>/dev/null |
      sed -n 's|^\(/nix/store/[^/]*\).*|\1|p' | sort -u |
      while read -r p; do printf '%s\0' --ro-bind-try "$p" "$p"; done
  '';

  # jail.nix's network combinator binds these /etc entries and follows their
  # store targets with `nix-store --query --requisites`. A jail has no store
  # database, so the query fails ("path … is not valid") and the form is left
  # with dangling links: no TLS, no /etc/hosts. This binds what the query would
  # have (DEC-125). On the host the database exists and this adds nothing.
  formStoreBinds = c: [
    (c.add-runtime ''
      if [ ! -e /nix/var/nix/db ]; then
        mapfile -d "" -t etc_binds < <(${etcStoreBinds} /etc/hosts /etc/nsswitch.conf /etc/resolv.conf /etc/ssl)
        RUNTIME_ARGS+=("''${etc_binds[@]}")
      fi
    '')
  ];
in {
  inherit etcStoreBinds formStoreBinds;
}
