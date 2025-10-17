_: {
  flake.nixosModules.webserver = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      caddy
    ];

    services = {
      static-web-server = {
        enable = true;
        root = "/var/www";
        listen = "[::]:80";

        configuration = {
          general = {
            directory-listing = true;
          };
        };
      };
    };
  };
}
