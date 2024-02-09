{ config, pkgs, ... }:

{
  nix.settings.allowed-users = [ "@wheel" "root" ];
  security.sudo.execWheelOnly = true;
  services.openssh = {
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      LogLevel = "ERROR";
    };
    extraConfig = ''
      IgnoreRhosts yes
      HostbasedAuthentication no
      PermitEmptyPasswords no
      AuthenticationMethods publickey
    '';
  };
  users.mutableUsers = false;
}