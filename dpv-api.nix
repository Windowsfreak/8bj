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
    after = [ "network.target" ];
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
  security.sudo.extraRules = [
    {
      users = [ "dpv" ];
      commands = [
        {
          command = "/usr/bin/systemctl restart dovecot2.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/usr/bin/systemctl restart postfix-setup.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/usr/bin/systemctl restart postfix.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}