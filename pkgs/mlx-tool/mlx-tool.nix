{ stdenv
, fetchFromGitHub
,
}:
stdenv.mkDerivation {
  pname = "mlnx-irq-affinity";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "Mellanox";
    repo = "mlnx-tools";
    rev = "cff8394223e901b9d60f7f7df40eb47b13875747";
    sha256 = "1ih64iap0yky825yacl42yk7bhvigl0cacfmxlbc9hl3pkxgr95q";
  };
  patches = [
    ./irq-loop.patch
    ./old-kernel.patch
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp sbin/common_irq_affinity.sh $out/bin/common_irq_affinity.sh
    cp sbin/set_irq_affinity.sh $out/bin/set_irq_affinity.sh
    cp sbin/set_irq_affinity_bynode.sh $out/bin/set_irq_affinity_bynode.sh
    cp sbin/set_irq_affinity_cpulist.sh $out/bin/set_irq_affinity_cpulist.sh
    cp sbin/show_irq_affinity.sh $out/bin/show_irq_affinity.sh
    cp sbin/show_irq_affinity_hints.sh $out/bin/show_irq_affinity_hints.sh
  '';
}
