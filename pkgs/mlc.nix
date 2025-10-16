{ stdenv, fetchurl, patchelf }:
stdenv.mkDerivation {
  pname = "mlc";
  version = "3.12";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/866182/mlc_v3.12.tgz";
    sha256 = "sha256-S492hdcZmN1dRFQyq0DCEVFYRiv801kROuVRqE4lDFA=";
  };

  sourceRoot = "Linux";

  installPhase = ''
    install -Dm755 mlc $out/bin/mlc
  '';

  nativeBuildInputs = [ patchelf ];

  fixupPhase = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/mlc
  '';
}
