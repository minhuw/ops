{ stdenv, pciutils }:
stdenv.mkDerivation {
  pname = "ddio-tune";
  version = "0.0.1";

  src = ./.;

  buildInputs = [
    pciutils
  ];

  installPhase = ''
    mkdir -p $out/bin
    gcc -o $out/bin/ddio-tune ddio-tune.c -lpci
  '';
}
