{pkgs, ...}: {
  environment.systemPackages = [
    # libsodium-sys needs its vendored C source: cargoSetupHook's system-lib
    # mode fails this recipe (ISS-028, probe in workarounds/default.nix).
    (pkgs.rustdesk-flutter.overrideAttrs {dontCargoUseSystemLibs = true;})
  ];
  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.relayHosts = ["sleipnir.bandicoot-sunfish.ts.net"];
  };
}
