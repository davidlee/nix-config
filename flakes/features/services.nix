# Services features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "avahi";
    nixos = _: {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  }

  {
    name = "printing";
    requires = ["services.avahi"];
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      # Direct driverless (IPP Everywhere) queues; addresses are reserved on
      # the router. Each PPD was captured from its printer: `model =
      # "everywhere"` would query the printer from cups.service's postStart,
      # so CUPS would fail to start whenever a printer is off.
      printers = [
        {
          name = "canon";
          description = "Canon TR8600 series";
          address = "192.168.0.4";
          ppd = ./services/canon-tr8600.ppd;
        }
        {
          name = "laser";
          description = "Brother HL-L2445DW";
          address = "192.168.0.30";
          ppd = ./services/brother-hl-l2445dw.ppd;
        }
      ];

      ppdModel = printer: "${printer.name}.ppd";

      printerPpds = pkgs.runCommand "printer-ppds" {} (lib.concatMapStrings (printer: ''
          install -Dm444 ${printer.ppd} $out/share/cups/model/${ppdModel printer}
        '')
        printers);
    in {
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          brlaser # Brother HL-L2445DW
          gutenprint # broad Canon/inkjet support
          gutenprintBin
          printerPpds
        ];
        # Its auto-created implicitclass queues fail to pick a destination
        # and stall jobs; the direct queues above replace them.
        browsed.enable = false;
      };

      hardware.printers = {
        ensurePrinters =
          map (printer: {
            inherit (printer) name description;
            deviceUri = "ipp://${printer.address}/ipp/print";
            model = ppdModel printer;
          })
          printers;
        ensureDefaultPrinter = "laser";
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
    name = "scanning";
    requires = ["services.avahi"];
    nixos = {
      username,
      pkgs,
      ...
    }: {
      # Driverless network scanning (eSCL/WSD) via mDNS discovery; covers the
      # Canon TR8660. airscan supersedes the built-in escl backend, which would
      # list the same device twice.
      hardware.sane = {
        enable = true;
        extraBackends = [pkgs.sane-airscan];
        disabledDefaultBackends = ["escl"];
      };

      users.users.${username}.extraGroups = ["scanner" "lp"];

      environment.systemPackages = [pkgs.simple-scan];
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
    };
  }

  {
    name = "webserver";
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        caddy
      ];

      networking.firewall.allowedTCPPorts = [80 443];

      # Vendored C deps: cargoSetupHook's system-lib mode fails this recipe
      # (ISS-028, probe in workarounds/default.nix). An overlay, because the
      # module has no `package` option.
      nixpkgs.overlays = [
        (_: prev: {
          static-web-server = prev.static-web-server.overrideAttrs {dontCargoUseSystemLibs = true;};
        })
      ];

      services = {
        static-web-server = {
          enable = true;
          root = "/var/www";
          listen = "[::]:80";

          configuration = {
            general = {
              directory-listing = false;
            };
          };
        };
      };
    };
  }

  # Port 22 lives with the daemon that listens on it (DEC-044).
  {
    name = "ssh";
    nixos = _: {
      services = {
        fail2ban.enable = true;
        openssh = {
          enable = true;
          settings = {
            GatewayPorts = "yes";
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            X11Forwarding = false;
            PermitRootLogin = "no";
            UseDns = true;
          };
        };
      };
      networking.firewall.allowedTCPPorts = [22];
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
