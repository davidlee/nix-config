# Services features, in projection order. Shape: README § Feature tree.
[
  {
    name = "printing";
    nixos = {pkgs, ...}: {
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          brlaser # Brother HL-L2445DW
          gutenprint # broad Canon/inkjet support
          gutenprintBin
        ];
      };

      # static resolution for printers — CUPS' ipp backend
      # can't resolve .local via avahi in its sandbox
      networking.extraHosts = ''
        192.168.0.30 BRWC8A3E8DADA55.local
      '';

      environment.systemPackages = with pkgs; [
        system-config-printer
      ];
    };
  }

  {
    name = "postgresql";
    nixos = {
      username,
      pkgs,
      ...
    }: {
      services = {
        postgresql = {
          package = pkgs.postgresql_18;
          enable = true;
          ensureUsers = [
            {
              name = username;
              ensureDBOwnership = true;
              ensureClauses = {
                superuser = true;
                createrole = true;
                createdb = true;
              };
            }
          ];
          ensureDatabases = [
            username
            "corpus"
          ];
          enableTCPIP = false;
        };
      };
      # Stray ports, kept for no behaviour change; they leave in SL-007 PHASE-06.
      networking.firewall.allowedTCPPorts = [80 443];
    };
  }

  {
    name = "webserver";
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        caddy
      ];

      networking.firewall.allowedTCPPorts = [80 443];

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

  {
    name = "sunshine";
    nixos = {pkgs, ...}: {
      services = {
        sunshine = {
          enable = true;
          openFirewall = true;
          capSysAdmin = true;
          # capSysNice = true;
          autoStart = false;
        };
      };

      environment = {
        systemPackages = with pkgs; [
          moonlight-qt
          sunshine
        ];
      };
    };
  }
]
