{pkgs ? import <nixpkgs> {}}:

pkgs.stdenv.mkDerivation {
  name = "custom_scripts";
  src = ./custom_scripts;
  installPhase = ''
    mkdir $out
    cp -r bin $out/bin
    cp -r share $out/share
  '';
}
