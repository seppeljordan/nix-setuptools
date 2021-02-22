{
  description =
    "A tool to parse setuptools configuration files (setup.cfg) with nix";

  inputs = {
    nix-parsec.url = "github:seppeljordan/nix-parsec";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nix-parsec, flake-utils, nixpkgs }:
    let
      systemDependent = flake-utils.lib.eachDefaultSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          checks = import ./tests.nix {
            inherit (self.lib) setuptools;
            inherit (pkgs) writeTextFile;
            inherit (nixpkgs) lib;
          };
        });
    in {
      lib = {
        setuptools = import ./setuptools.nix {
          inherit (nixpkgs) lib;
          parsec = nix-parsec.lib.parsec;
        };
      };
    } // systemDependent;
}
