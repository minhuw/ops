{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage {
  pname = "core-to-core-latency";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "nviennot";
    repo = "core-to-core-latency";
    rev = "96a943ac384b78bf54252068f25e2f891bfadc60";
    sha256 = "sha256-Vbswp+E1Kbd8GHDg8J/MmfVYoKwraXgCIYk8D3MOlGw=";
  };

  cargoHash = "sha256-La1mAp4VX9NSaWxYcLSQCu7TwpuYieIWc67glQrEBrk=";

  meta.mainProgram = "core-to-core-latency";
}
