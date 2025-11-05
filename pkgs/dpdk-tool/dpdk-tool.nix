{ stdenv
, fetchFromGitHub
, python3
,
}:
stdenv.mkDerivation {
  pname = "dpdk-usertools";
  version = "24.11.0";
  src = fetchFromGitHub {
    owner = "DPDK";
    repo = "dpdk";
    rev = "v24.11";
    sha256 = "sha256-KN7OKulZIfj+juo8TxYrMvGqsdL2tW/nEGkKjAB9HBY=";
  };
  nativeBuildInputs = [ python3 ];
  installPhase = ''
    mkdir -p $out/bin
    cp usertools/cpu_layout.py $out/bin/cpu_layout.py
    cp usertools/dpdk-devbind.py $out/bin/dpdk-devbind.py
    cp usertools/dpdk-hugepages.py $out/bin/dpdk-hugepages.py
    cp usertools/dpdk-pmdinfo.py $out/bin/dpdk-pmdinfo.py
    cp usertools/dpdk-rss-flows.py $out/bin/dpdk-rss-flows.py
    cp usertools/dpdk-telemetry-client.py $out/bin/dpdk-telemetry-client.py
    cp usertools/dpdk-telemetry-exporter.py $out/bin/dpdk-telemetry-exporter.py
    cp usertools/dpdk-telemetry.py $out/bin/dpdk-telemetry.py
    chmod +x $out/bin/*.py
  '';
}