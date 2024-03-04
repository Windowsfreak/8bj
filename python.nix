let
  pkgs = import <nixpkgs> {};
  pythonPackages = pkgs.python3.withPackages (ps: with ps; [
    numpy
    pillow
    pyvips
  ]);
in
  pythonPackages