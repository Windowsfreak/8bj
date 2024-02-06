{ config, pkgs, ... }:

{
  nix.settings.allowed-users = [ "@wheel" "root" ];
  security.sudo.execWheelOnly = true;
  services.openssh = {
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
    extraConfig = ''
      IgnoreRhosts yes
      HostbasedAuthentication no
      PermitEmptyPasswords no
      AuthenticationMethods publickey
    '';
  };
  users.mutableUsers = false;
}