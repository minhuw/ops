{ fetchFromGitHub, stdenv, python3, pkg-config, cmake, ninja, numactl, pciutils, rdma-core, libpcap, libbsd, util-linux }:
let 
  dpdk = stdenv.mkDerivation {
    pname = "dpdk";
    version = "24.11";

    src = fetchFromGitHub {
      owner = "dpdk";
      repo = "dpdk";
      rev = "v24.11";
      sha256 = "sha256-KN7OKulZIfj+juo8TxYrMvGqsdL2tW/nEGkKjAB9HBY=";
    };

    buildInputs = [
      numactl
      libpcap
    ];

    propagatedBuildInputs = [
      rdma-core
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
  pname = "pktgen";
  version = "24.10.3";

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
    rev = "12fb93c72d57288b8b77cf628e15de96292358eb";
    sha256 = "sha256-6KC1k+LWNSU/mdwcUKjCaq8pGOcO+dFzeXX4PJm0QgE=";
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
