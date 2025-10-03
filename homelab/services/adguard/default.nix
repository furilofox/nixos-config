{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.adguard;
  homelabCfg = config.homelab;
in {
  options.homelab.adguard = {
    enable = lib.mkEnableOption "AdGuard Home DNS and DHCP server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for AdGuard Home web interface";
    };

    dnsPort = lib.mkOption {
      type = lib.types.port;
      default = 53;
      description = "Port for DNS server";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/adguard";
      description = "Data directory for AdGuard Home";
    };
  };

  config = lib.mkIf (homelabCfg.enable && cfg.enable) {
    services.adguardhome = {
      enable = true;
      port = cfg.port;
      host = "0.0.0.0";
      openFirewall = true;
      mutableSettings = false;
      settings = {
        users = [
          {
            name = "fabian";
            password = "$2y$10$nuohosih.b1j32IYTkuybOJZW3wXcXG/R2E2nBJTpWISYWlvkK1Kq";
          }
        ];
        dns = {
          bind_hosts = ["0.0.0.0"];
          port = cfg.dnsPort;
          upstream_dns = [
            "https://security.cloudflare-dns.com/dns-query"
            "https://base.dns.mullvad.net/dns-query"
            "https://dns.quad9.net/dns-query"
            "https://dns.de.futuredns.eu.org/dns-query/"
          ];
          bootstrap_dns = [
            "1.1.1.1"
            "1.0.0.1"
            "8.8.8.8"
          ];
        };
        filtering = {
          rewrites = [
            {
              domain = "*.home";
              answer = "192.168.20.10";
            }
          ];
        };
        dhcp = {
          enabled = true;
          interface_name = "enp2s0";
          dhcpv4 = {
            gateway_ip = "192.168.20.1";
            subnet_mask = "255.255.255.0";
            range_start = "192.168.20.100";
            range_end = "192.168.20.200";
            lease_duration = 2592000; # 30 Days
          };
        };
        clients = {
          runtime_sources = {
            whois = true;
            arp = true;
            rdns = true;
            dhcp = true;
            hosts = true;
          };
          persistent = [
            {
              name = "Desktop - Pandora";
              ids = [
                "192.168.20.21"
              ];
              tags = [
                "device_pc"
              ];
            }
            {
              name = "Laptop - Promethea";
              ids = [
                "192.168.20.22"
              ];
              tags = [
                "device_laptop"
              ];
            }
            {
              name = "Oneplus 13";
              ids = [
                "192.168.20.23"
              ];
              tags = [
                "device_phone"
              ];
            }
            {
              name = "Server (Athenas)";
              ids = [
                "192.168.20.10"
                "127.0.0.1"
              ];
              tags = [
                "device_nas"
              ];
            }
          ];
        };
        log_compress = false;
        log_localtime = false;
        log_max_backups = 0;
        log_max_size = 100;
        log_max_age = 3;
        log_file = "";
        verbose = false;
        os = {
          group = "";
          user = "";
          rlimit_nofile = 0;
        };
        schema_version = 27;
      };
    };

    # Open DNS port in firewall
    networking.firewall.allowedUDPPorts = [cfg.dnsPort];
    networking.firewall.allowedTCPPorts = [cfg.port];

    # Create systemd service to ensure proper startup order
    systemd.services.adguardhome = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };
  };
}
