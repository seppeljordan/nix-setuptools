{
  description =
    "A tool to parse setuptools configuration files (setup.cfg) with nix";

  inputs = {
    nix-parsec.url = "github:nprindle/nix-parsec";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nix-parsec, flake-utils, nixpkgs }:
    let
      module = import ./module.nix { inherit (nixpkgs) lib; };
      systemDependent = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          packaging = self.lib.packaging { python = pkgs.python3; };
          tests = module.makeModuleTree {
            inherit (self.lib) setuptools;
            inherit (pkgs) writeTextFile python;
            inherit (nixpkgs) lib;
            inherit (packaging) buildSetuptoolsPackage;
          } ./tests.nix;
        in {
          devShell = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
          checks = tests.allTests;
        });

    in {
      lib = module.makeModuleTree {
        inherit (nixpkgs) lib;
        inherit (nix-parsec.lib) parsec;
      } ./lib.nix;
    } // systemDependent;
}
