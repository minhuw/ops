{ fetchFromGitHub, stdenv, libarchive, libbsd, libexecinfo, libelf, libbpf, ninja, openssl, python3, rdma-core, dtc, numactl, pkg-config, libpcap, jansson, mstflint, zlib }:
stdenv.mkDerivation {
  pname = "dpdk-testpmd";
  version = "24.03";

  src = fetchFromGitHub {
    owner = "dpdk";
    repo = "dpdk";
    rev = "v24.03";
    sha256 = "sha256-BaGBi/EVSOR0abiMKhLUQIK/TZUYm4vLl9a5TGtSUvo=";
  };

  hardeningDisable = [ "fortify" ];

  buildInputs = [
    numactl
    libarchive
    libpcap
    libbsd
    libexecinfo
    libelf
    libbpf
    jansson
    openssl
    dtc
    mstflint
    zlib
  ];

  propagatedBuildInputs = [
    rdma-core
  ];

  nativeBuildInputs = [
    ninja
    pkg-config
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
}
