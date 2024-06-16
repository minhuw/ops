{ fetchFromGitHub, stdenv, python3, pkg-config, cmake, ninja, numactl, pciutils, rdma-core, libpcap, libbsd, util-linux }:
let 
  dpdk = stdenv.mkDerivation {
    pname = "dpdk";
    version = "24.05";

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
      meson setup --prefix=$out -Denable_docs=false -Dtests=false -Denable_apps="test-pmd" -Dbuildtype=release $(pwd)/build
    '';

    buildPhase = ''
      meson compile -C $(pwd)/build
    '';

    installPhase = ''
      meson install -C $(pwd)/build
    '';
  };
in
stdenv.mkDerivation {
  pname = "dpdk-pktgen";
  version = "24.05.5";

  buildInputs = [
    libbsd
    libpcap
    numactl
  ];

  propagatedBuildInputs = [
    pciutils
    util-linux
    dpdk
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    (python3.withPackages (ps: with ps; [ pyelftools meson ]))
  ];

  src = fetchFromGitHub {
    owner = "pktgen";
    repo = "Pktgen-DPDK";
    rev = "f53800db12a81c5552606c126f65b0b3a3d943a0";
    sha256 = "sha256-SGvYl51owTkenXAJIBNpn+EdGluxm8omGt5VQpTxW7g=";
  };

  postPatch = ''
    substituteInPlace lib/common/lscpu.h --replace /usr/bin/lscpu ${util-linux}/bin/lscpu
  '';

  configurePhase = ''
    patchShebangs .
  '';

  buildPhase = ''
    make build
  '';

  installPhase = ''
    make install
    mkdir $out
    mkdir $out/bin
    cp usr/local/bin/* $out/bin
  '';
}
