{ pkgs ? import <nixpkgs> {} }:
{
  mlc = pkgs.callPackage ./pkgs/mlc.nix { };
  dpdk-pktgen = pkgs.callPackage ./pkgs/dpdk-pktgen.nix { };
  dpdk-testpmd = pkgs.callPackage ./pkgs/dpdk.nix { };
  spectre-checker = pkgs.callPackage ./pkgs/spectre-checker.nix { };
  ddio-tune = pkgs.callPackage ./pkgs/ddio-tune/ddio-tune.nix { };
  pqrs = pkgs.callPackage ./pkgs/pqrs.nix { };
  piperf = pkgs.callPackage ./pkgs/piperf.nix { };
  fio = pkgs.callPackage ./pkgs/fio.nix { };
  inherit (pkgs.callPackage ./pkgs/bpftrace/bpftrace.nix { })
    gro_dist
    gro_ldist
    recv_dist;
}
