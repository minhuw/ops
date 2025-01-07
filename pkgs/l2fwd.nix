{ fetchFromGitHub, stdenv, ninja, python3, pkg-config, rdma-core, numactl, libpcap }:
stdenv.mkDerivation {
  pname = "dpdk-l2fwd";
  version = "24.03";

  src = fetchFromGitHub {
    owner = "dpdk";
    repo = "dpdk";
    rev = "v24.03";
    sha256 = "sha256-BaGBi/EVSOR0abiMKhLUQIK/TZUYm4vLl9a5TGtSUvo=";
  };

  buildInputs = [
    numactl
    rdma-core
    libpcap
  ];

  nativeBuildInputs = [
    ninja
    (python3.withPackages (ps: with ps; [ pyelftools meson ]))
  ];

  configurePhase = ''
    meson setup --prefix=$out -Denable_docs=false -Dtests=false -Denable_apps="test-pmd" -Dexamples=l2fwd -Dbuildtype=release $(pwd)/build
  '';

  buildPhase = ''
    meson compile -C $(pwd)/build
  '';

  installPhase = ''
    meson install -C $(pwd)/build
    cp -r $(pwd)/build/examples/dpdk-l2fwd $out/bin
  '';
}
