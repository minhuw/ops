{ pkgs ? import <nixpkgs> {} }:
{
  mlc = pkgs.callPackage ./pkgs/mlc.nix { };
  dpdk-pktgen = pkgs.callPackage ./pkgs/dpdk-pktgen.nix { };
  spectre-checker = pkgs.callPackage ./pkgs/spectre-checker.nix { };
  ddio-tune = pkgs.callPackage ./pkgs/ddio-tune/ddio-tune.nix { };
}
