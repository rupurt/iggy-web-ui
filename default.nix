{
  config,
  lib,
  dream2nix,
  ...
}: {
  imports = [
    # dream2nix.modules.dream2nix.nodejs-package-lock-v3
    # dream2nix.modules.dream2nix.nodejs-granular-v3
    dream2nix.modules.dream2nix.nodejs-devshell-v3
  ];

  deps = {nixpkgs, ...}: {
    inherit
      (nixpkgs)
      fetchFromGithub
      mkShell
      stdenv
      ;
  };
  env = {
    NODE_ENV = "development";
  };
  mkDerivation = {
    src = ./.;
    buildPhase = "mkdir $out";
  };

  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  name = "iggy-web-ui";
  version = "0.0.1";
}
