{ stdenv, bpftrace, writeScriptBin }:
{
  gro_dist = writeScriptBin "gro_dist" ''
    #!${stdenv.shell}
    exec sudo ${bpftrace}/bin/bpftrace ${./gro_dist.bt} "$@"
  '';
  gro_ldist = writeScriptBin "gro_ldist" ''
    #!${stdenv.shell}
    exec sudo ${bpftrace}/bin/bpftrace ${./gro_ldist.bt} "$@"
  '';
  recv_dist = writeScriptBin "recv_dist" ''
    #!${stdenv.shell}
    exec sudo ${bpftrace}/bin/bpftrace ${./recv_dist.bt} "$@"
  '';
}