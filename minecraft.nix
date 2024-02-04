{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pkgs.jdk21_headless
  ];
}