{ config, pkgs, ... }:

let
  ipv4 = "37.114.34.98";
  gwv4 = "37.114.34.1";
  ipv6 = "2a00:ccc1:102:147::1";
  gwv6 = "fe80::1";
in
{
  imports = [
  ];
  networking = {
    hostName = "8bj";
    firewall = {
      allowedTCPPorts = [ 22 80 443 8529 8123 993 995 465 ];
      allowedUDPPorts = [ 443 51820 ];
      logRefusedConnections = false;
    };
    useDHCP = false;
    interfaces.ens18 = {
      ipv4.addresses = [ {
        address = ipv4;
        prefixLength = 24;
      } ];
      ipv6.addresses = [ {
        address = ipv6;
        prefixLength = 64;
      } ];
    };
    defaultGateway = gwv4;
    defaultGateway6 = {
      address = gwv6;
      interface = "ens18";
    };
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    nat = {
      enable = true;
      externalInterface = "ens18";
      internalInterfaces = [ "wg0" ];
    };
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ens18 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ens18 -j MASQUERADE
      '';
      privateKeyFile = "/var/config/wireguard/private.key";
      peers = [
        { # i7
          publicKey = "8GDBnOggqwchSPeLEvOCP16zdDRwP2his5PoyIQ5I3o=";
          allowedIPs = [ "10.100.0.2/32" "10.100.0.3/32" "10.100.0.4/32" "10.100.0.5/32" "10.100.0.6/32" ];
        }
        { # P3
          publicKey = "LG+wIgcsZZ1cHSfqLP3tNQH7v9NBR0tE/8ae0bw+zmo=";
          allowedIPs = [ "10.100.0.7/32" "10.100.0.8/32" "10.100.0.9/32" "10.100.0.10/32" "10.100.0.11/32" ];
        }
      ];
    };
  };
}