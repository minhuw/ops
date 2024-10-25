{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "ddio-tune.sh";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "pmem";
    repo = "rpma";
    rev = "f52c00d18821ac573a71e9f23a6d2e8695086e95";
    sha256 = "sha256-QO/Ya45XH91cC3m7kxxIgU4LeRs66nwYNZyZ0ikghI8=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${src}/tools/ddio.sh $out/bin/ddio-tune.sh
  '';
}
