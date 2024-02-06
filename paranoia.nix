{ config, pkgs, ... }:

{
  nix.allowedUsers = [ "@wheel" "root" ];
  security.sudo.execWheelOnly = true;
  services.openssh = {
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = false;
    extraConfig = ''
      IgnoreRhosts yes
      HostbasedAuthentication no
      PermitEmptyPasswords no
      AuthenticationMethods publickey
    '';
  };
  users.mutableUsers = false;
}