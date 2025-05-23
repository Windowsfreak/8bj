{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  environment.systemPackages = with pkgs; [
    gnumake
    unstable.go_1_24
    (import ./python.nix)
    exiftool
    vips
    nodejs
  ];

  systemd.services.dpv1 = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/dpv1/apiserver.sock
      exec /var/dpv/api/bin/endpoint1
    '';
    serviceConfig = {
      WorkingDirectory = "/var/dpv/api";
      RuntimeDirectory = "dpv1";
      User = "dpv";
      Group = "dpv";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
  systemd.services.dpv2 = {
    #wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/dpv2/apiserver.sock
      exec /var/dpv/api/bin/endpoint1
    '';
    serviceConfig = {
      WorkingDirectory = "/var/dpv/api";
      RuntimeDirectory = "dpv2";
      User = "dpv";
      Group = "dpv";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
