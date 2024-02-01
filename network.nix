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
      allowedTCPPorts = [ 22 80 443 8529 ];
      allowedUDPPorts = [ 443 ];
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
  };
}