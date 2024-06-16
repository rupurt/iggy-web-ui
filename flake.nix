{
  description = "Iggy Web UI. Persistent message streaming platform written in Rust";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
  };

  outputs = {
    self,
    dream2nix,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (supportedSystem:
        f {
          system = supportedSystem;
          pkgs = dream2nix.inputs.nixpkgs.legacyPackages.${supportedSystem};
        });
  in {
    packages = forEachSupportedSystem ({pkgs, ...}: rec {
      default = dream2nix.lib.evalModules {
        packageSets.nixpkgs = pkgs;
        modules = [
          ./default.nix
          {
            paths.projectRoot = ./.;
            paths.projectRootFile = "flake.nix";
            paths.package = ./.;
          }
        ];
      };
    });

    formatter = forEachSupportedSystem ({pkgs, ...}: pkgs.alejandra);

    devShells = forEachSupportedSystem ({
      system,
      pkgs,
      ...
    }: {
      default = pkgs.mkShell {
        inputsFrom = [
          self.packages.${system}.default.devShell
        ];

        packages = [];
      };
    });

    overlay = final: prev: {
      iggy-pkgs = self.packages.${prev.system};
    };
  };
}
