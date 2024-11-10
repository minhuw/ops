{ fetchFromGitHub, rustPlatform }:
rustPlatform.buildRustPackage {
    pname = "pqrs";
    version = "0.3.2";

    src = fetchFromGitHub {
      owner = "manojkarthick";
      repo = "pqrs";
      rev = "v0.3.2";
      sha256 = "sha256-0oSSoGZga0OGAKUNsLmKkUl8N1l0pVi4KIqrKJbeVVU=";
    };

    cargoSha256 = "sha256-w0WD+EtVGFMGpS4a2DJrLdbunwF2yiONKQwdcQG2EB0=";
}
