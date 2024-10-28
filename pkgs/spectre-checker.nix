
{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "spectre-meltdown-checker.sh";
  version = "0.46";

  src = fetchFromGitHub {
    owner = "speed47";
    repo = "spectre-meltdown-checker";
    rev = "34c6095912d115551f69435a55d6e0445932fdf9";
    sha256 = "sha256-m0f0+AFPrB2fPNd1SkSj6y9PElTdefOdI51Jgfi816w=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${src}/spectre-meltdown-checker.sh $out/bin
  '';
}
