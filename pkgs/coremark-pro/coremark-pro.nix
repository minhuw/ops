{ stdenv, fetchFromGitHub, perl }:
let
  coremark-pro = stdenv.mkDerivation {
    pname = "coremark-pro";
    version = "1.1.2743";

    src = fetchFromGitHub {
      owner = "eembc";
      repo = "coremark-pro";
      rev = "v1.1.2743";
      sha256 = "sha256-cx/AD8kJ6U2lk7pk77hz8DykOOuMtr4a7rAUMmbBqw0=";
    };

    nativeBuildInputs = [ perl ];

    patchPhase = ''
      substituteInPlace Makefile --replace-fail "SHELL=bash" "SHELL=${stdenv.shell}"
      substituteInPlace util/make/linux64.mak --replace-fail "SHELL=/bin/bash" "SHELL=${stdenv.shell}"
      substituteInPlace util/make/gcc64.mak \
        --replace-fail 'CC		= $(TOOLS)/bin/gcc' 'CC		= gcc' \
        --replace-fail 'AS		= $(TOOLS)/bin/as' 'AS		= as' \
        --replace-fail 'LD		= $(TOOLS)/bin/gcc' 'LD		= gcc' \
        --replace-fail 'AR		= $(TOOLS)/bin/ar' 'AR		= ar' \
        --replace-fail 'SIZE	= $(TOOLS)/bin/size' 'SIZE	= size'
    '';

    buildPhase = ''
      make TARGET=linux64 build
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp builds/linux64/gcc64/bin/*.exe $out/bin/
      for f in $out/bin/*.exe; do
        mv "$f" "''${f%.exe}"
      done
    '';
  };
  withMainProgram = name: coremark-pro.overrideAttrs (old: {
    meta = (old.meta or {}) // { mainProgram = name; };
  });
in {
  inherit coremark-pro;
  core = withMainProgram "core";
  cjpeg-rose7-preset = withMainProgram "cjpeg-rose7-preset";
  linear_alg-mid-100x100-sp = withMainProgram "linear_alg-mid-100x100-sp";
  loops-all-mid-10k-sp = withMainProgram "loops-all-mid-10k-sp";
  nnet_test = withMainProgram "nnet_test";
  parser-125k = withMainProgram "parser-125k";
  radix2-big-64k = withMainProgram "radix2-big-64k";
  sha-test = withMainProgram "sha-test";
  zip-test = withMainProgram "zip-test";
}
