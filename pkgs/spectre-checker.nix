
{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "spectre-meltdown-checker.sh";
  version = "0.46";

  src = fetchFromGitHub {
    owner = "speed47";
    repo = "spectre-meltdown-checker";
    rev = "bd0c7c94b5dded3b3178620fc8d166f98cdf503d";
    sha256 = "sha256-hVezGMyujSdeljitsXLNMVZvSc00UTEqmC+tm/9C6nM=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${src}/spectre-meltdown-checker.sh $out/bin
  '';
}
