{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation {
  pname = "gapbs";
  version = "2024";

  src = fetchFromGitHub {
    owner = "sbeamer";
    repo = "gapbs";
    rev = "b5e3e19c2845f22fb338f4a4bc4b1ccee861d026";
    sha256 = "sha256-E1s9E+vOsQfBBOdTyNbtLdOV6LIrF19wzMR3V67L7w0=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r bc $out/bin/gapbs-bc
    cp -r bfs $out/bin/gapbs-bfs
    cp -r cc $out/bin/gapbs-cc
    cp -r cc_sv $out/bin/gapbs-cc-sv
    cp -r pr $out/bin/gapbs-pr
    cp -r pr_spmv $out/bin/gapbs-pr-spmv
    cp -r sssp $out/bin/gapbs-sssp
    cp -r tc $out/bin/gapbs-tc
    cp -r converter $out/bin/gapbs-converter
  '';
}