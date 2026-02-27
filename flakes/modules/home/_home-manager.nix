_: {
  flake.nixosModules.home-manager = {
    self,
    username,
    inputs,
    specialArgs,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.backupFileExtension = "backup";
        home-manager.users.${username} = self.homeModules.Sleipnir;
      }
    ];
  };
}
