{ stdenv, fetchurl, patchelf }:
stdenv.mkDerivation rec {
  pname = "mlc";
  version = "3.10";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/763324/mlc_v${version}.tgz";
    sha256 = "sha256-Ob3EZ9E07UNWHmIu/mZNYs3uFHv4e/MJDypW+GMT14k=";
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
