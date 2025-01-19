{ stdenv, fetchurl, patchelf }:
stdenv.mkDerivation rec {
  pname = "mlc";
  version = "3.11b";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/834254/mlc_v3.11b.tgz";
    sha256 = "sha256-XVq9J9FFr1nVZMnFOTgwGgggXwdbm9QfL5K0yO/rKCQ=";
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
