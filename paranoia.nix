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
      UseDns = false;
    };
    extraConfig = ''
      IgnoreRhosts yes
      HostbasedAuthentication no
      PermitEmptyPasswords no
      AuthenticationMethods publickey
    '';
  };
  programs.ssh.extraConfig = ''
    Host github.com gitlab.com
      AddressFamily inet
      GSSAPIAuthentication no
  '';
  users.mutableUsers = false;
}