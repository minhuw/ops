{ pkgs ? import <nixpkgs> {} }:
{
  mlc = pkgs.callPackage ./pkgs/mlc.nix { };
  dpdk-pktgen = pkgs.callPackage ./pkgs/dpdk-pktgen.nix { };
}
