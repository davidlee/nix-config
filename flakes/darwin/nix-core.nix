_: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.lix.systems"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];

      builders-use-substitutes = true;
      show-trace = true;
      log-lines = 50;
    };
    gc = {
      automatic = true;
      interval = [
        {
          Hour = 12;
          Minute = 15;
        }
      ];
    };
  };
}
