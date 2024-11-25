{
  description = "Personal Software Index";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let 
      systems = [
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in
  {
    packages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      }
    );
    apps = forAllSystems (system: {
      gro-dist = {
        type = "app";
        program = "${self.packages.${system}.gro_dist}/bin/gro_dist";
      };
    });
  };
}
