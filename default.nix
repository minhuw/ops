{ pkgs ? import <nixpkgs> {} }:
{
  mlc = pkgs.callPackage ./pkgs/mlc.nix { };
  dpdk-pktgen = pkgs.callPackage ./pkgs/dpdk-pktgen.nix { };
  dpdk-testpmd = pkgs.callPackage ./pkgs/dpdk.nix { };
  dpdk-l3fwd = pkgs.callPackage ./pkgs/dpdk-l3fwd.nix { };
  spectre-checker = pkgs.callPackage ./pkgs/spectre-checker.nix { };
  ddio-tune = pkgs.callPackage ./pkgs/ddio-tune/ddio-tune.nix { };
  pqrs = pkgs.callPackage ./pkgs/pqrs.nix { };
  piperf = pkgs.callPackage ./pkgs/piperf.nix { };
  fio = pkgs.callPackage ./pkgs/fio.nix { };
  gapbs = pkgs.callPackage ./pkgs/gapbs.nix { };
  osjitter = pkgs.callPackage ./pkgs/osjitter.nix { };
  mlx-tool = pkgs.callPackage ./pkgs/mlx-tool/mlx-tool.nix { };
  dpdk-tool = pkgs.callPackage ./pkgs/dpdk-tool/dpdk-tool.nix { };
  toplev = pkgs.callPackage ./pkgs/toplev/toplev.nix { };
  inherit (pkgs.callPackage ./pkgs/bpftrace/bpftrace.nix { })
    gro_dist
    gro_ldist
    recv_dist
    napi_dist;
}
