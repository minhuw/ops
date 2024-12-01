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
}