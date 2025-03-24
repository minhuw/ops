{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation {
  pname = "osjitter";
  version = "v1.4";

  src = fetchFromGitHub {
    owner = "gsauthof";
    repo = "osjitter";
    rev = "acc72d96d2b70594b5cb1a0f552244e4e3e8a1eb";
    sha256 = "sha256-KsjYPv4Y5AxTVsUvP7QBy6ZcMKV3+MtqmvqH75bku0M=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp osjitter $out/bin/osjitter
  '';
}
