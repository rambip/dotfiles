{pkgs ? import <nixpkgs> {}}:

#let runtime = ''
#  #! /bin/sh
#  export PYTHONPATH=${pkgs.python38Packages.Wand}/lib/python3.8/site-packages/
#  export PATH=${pkgs.sway}/bin:${pkgs.xorg.xrdb}/bin
#  ${pkgs.python38}/bin/python $out/raw/random_wallpaper.py
#  '';

#in
  pkgs.stdenv.mkDerivation rec {
    name = "my_raw_scripts";
    src = ./.;
    installPhase = ''
    mkdir -p $out/bin
    # mkdir -p $out/raw
    # echo "{runtime}" > $out/bin/random_wallpaper
    # mv random_wallpaper.py $out/raw/random_wallpaper.py

    cp * $out/bin
    chmod +x $out/bin/*
    '';
  }
