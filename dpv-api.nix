{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnumake
    go
    nodejs
  ];

  systemd.services.dpv1 = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
      export UNIX=/var/run/dpv1/apiserver.sock
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
    after = [ "network.target" ];
    script = ''
      export UNIX=/var/run/apiserver2.sock
      exec /var/dpv/api/bin/endpoint1
    '';
    serviceConfig = {
      WorkingDirectory = "/var/dpv/api";
      User = "dpv";
      Group = "dpv";
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };

}