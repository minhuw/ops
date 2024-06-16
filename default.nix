{ system ? builtins.currentSystem }:
let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/cc54fb41d13736e92229c21627ea4f22199fee6b.tar.gz") { inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = {
    mlc = callPackage ./mlc.nix { };
  };
in
self
