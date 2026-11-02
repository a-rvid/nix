{ config, lib, ... }:
let
  peerPublicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
  wifiInterface = "wlp2s0";
in
{
  config = lib.mkIf config.my.secrets.enable {
    sops.secrets = {
      wifi-sam-min-katt-password.key = "wifiSamMinKattPassword";
      wifi-iphone-password.key = "wifiIPhonePassword";
      wifi-justnet-password.key = "wifiJustNetPassword";
      wifi-tele2-password.key = "wifiTele2Password";
      wireguard-private-key.key = "wireguardPrivateKey";
    };

    networking.networkmanager.ensureProfiles = {
      profiles = {
        "Sam Min Katt" = {
          connection = {
            id = "Sam Min Katt";
            uuid = "150eb470-1c6e-44d0-8926-1a1ec857c88a";
            type = "wifi";
            interface-name = wifiInterface;
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "Sam Min Katt";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk-flags = 1;
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };

        iPhone = {
          connection = {
            id = "iPhone";
            uuid = "00e69728-7458-4d1d-af34-33caf0926bd6";
            type = "wifi";
            interface-name = wifiInterface;
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "iPhone";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk-flags = 1;
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };

        JustNet = {
          connection = {
            id = "JustNet";
            uuid = "6dd13721-09f9-4877-ab7c-6077f2237d42";
            type = "wifi";
            interface-name = wifiInterface;
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "JustNet";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "sae";
            psk-flags = 1;
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };

        SJ = {
          connection = {
            id = "SJ";
            uuid = "a575f3e2-6f66-49d7-9484-8b2d8a8bdcfe";
            type = "wifi";
            interface-name = wifiInterface;
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "SJ";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };

        Tele2_E53226 = {
          connection = {
            id = "Tele2_E53226";
            uuid = "e2175725-49f5-4c82-b960-acd5b4a090e6";
            type = "wifi";
            interface-name = wifiInterface;
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "Tele2_E53226";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk-flags = 1;
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };

        segin = {
          connection = {
            id = "segin";
            uuid = "40be0921-02de-4598-b502-4b10bd725b6f";
            type = "wireguard";
            interface-name = "segin";
            autoconnect = true;
          };
          ipv4 = {
            address1 = "10.191.102.32/32";
            dns = "10.128.0.1";
            method = "manual";
          };
          ipv6 = {
            address1 = "fd7d:76ee:e68f:a993:d495:80a2:5a6a:56f5/128";
            dns = "fd7d:76ee:e68f:a993::1";
            method = "manual";
          };
          wireguard = {
            mtu = 1320;
            peer-routes = true;
            private-key-flags = 1;
          };
          "wireguard-peer.${peerPublicKey}" = {
            allowed-ips = "0.0.0.0/0;::/0;";
            endpoint = "94.185.80.228:1637";
            persistent-keepalive = 15;
          };
        };
      };

      secrets.entries = [
        {
          matchId = "Sam Min Katt";
          matchSetting = "802-11-wireless-security";
          key = "psk";
          file = config.sops.secrets.wifi-sam-min-katt-password.path;
        }
        {
          matchId = "iPhone";
          matchSetting = "802-11-wireless-security";
          key = "psk";
          file = config.sops.secrets.wifi-iphone-password.path;
        }
        {
          matchId = "JustNet";
          matchSetting = "802-11-wireless-security";
          key = "psk";
          file = config.sops.secrets.wifi-justnet-password.path;
        }
        {
          matchId = "Tele2_E53226";
          matchSetting = "802-11-wireless-security";
          key = "psk";
          file = config.sops.secrets.wifi-tele2-password.path;
        }
        {
          matchId = "segin";
          matchSetting = "wireguard";
          key = "private-key";
          file = config.sops.secrets.wireguard-private-key.path;
        }
      ];
    };
  };
}
