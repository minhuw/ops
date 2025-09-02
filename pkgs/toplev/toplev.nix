{ stdenv
, fetchFromGitHub
,
}:
stdenv.mkDerivation {
  pname = "pmu-tools";
  version = "22.04.20";
  src = fetchFromGitHub {
    owner = "minhuw";
    repo = "pmu-tools";
    rev = "4a1384f123ee680406697785548a70e40ec5e63a";
    sha256 = "sha256-mQrZrxhBrqzrVIlBKLczt+/0woa0idRfG8qoZuLWZko=";
  };
  installPhase = ''
    mkdir -p $out/bin
    cp toplev.py $out/bin/toplev.py
    cp tl_stat.py $out/bin/tl_stat.py
    cp tl_cpu.py $out/bin/tl_cpu.py
    cp tl_output.py $out/bin/tl_output.py
    cp ocperf.py $out/bin/ocperf.py
    cp dummyarith.py $out/bin/dummyarith.py
    cp event_download.py $out/bin/event_download.py
    cp tl_uval.py $out/bin/tl_uval.py
    cp tl_io.py $out/bin/tl_io.py
    cp listutils.py $out/bin/listutils.py
    cp objutils.py $out/bin/objutils.py
    cp pmudef.py $out/bin/pmudef.py
    cp msr.py $out/bin/msr.py
    cp latego.py $out/bin/latego.py
    cp pci.py $out/bin/pci.py
    cp perf_metrics.py $out/bin/perf_metrics.py
    cp *_ratios.py $out/bin/
  '';
}
