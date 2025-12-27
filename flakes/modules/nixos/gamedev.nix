_: {
  flake.nixosModules.gamedev = {pkgs, ...}: {
    environment = {
      systemPackages = with pkgs; [
        godot-mono
        omnisharp-roslyn
        dotnet-sdk_10
      ];
    };
  };
}
