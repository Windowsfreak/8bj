{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    unstable.go_1_24
    (import ./python.nix)
    exiftool
    vips
    nodejs
    sqlite
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
  systemd.services.zoom = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "arangodb.service" ];
    script = ''
      export UNIX=/run/zoom/apiserver.sock
      exec /var/dpv/zoom/bin/main
    '';
    serviceConfig = {
      WorkingDirectory = "/var/dpv/zoom";
      RuntimeDirectory = "zoom";
      User = "dpv";
      Group = "dpv";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
  systemd.services.dpv = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
      export UNIX=/run/dpv/apiserver.sock
      exec /var/dpv/dpv/bin/membership
    '';
    serviceConfig = {
      WorkingDirectory = "/var/dpv/dpv";
      RuntimeDirectory = "dpv";
      User = "dpv";
      Group = "dpv";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
