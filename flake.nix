{
  description =
    "A tool to parse setuptools configuration files (setup.cfg) with nix";

  inputs = {
    nix-parsec.url = "github:nprindle/nix-parsec";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nix-parsec, flake-utils, nixpkgs }:
    let
      systemDependent = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          callFunction = callFunctionWith {
            inherit (self.lib) setuptools;
            inherit (pkgs) writeTextFile;
            inherit (nixpkgs) lib;
            inherit callFunctionWith;
          };
        in {
          devShell = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
          checks = callFunction ./tests/test-parser.nix { };
        });
      callFunctionWith = autoArguments: functionOrPath: arguments:
        let
          f = if nixpkgs.lib.isFunction functionOrPath then
            functionOrPath
          else
            import functionOrPath;
          functionArguments = nixpkgs.lib.functionArgs f;
        in f (builtins.intersectAttrs functionArguments
          (autoArguments // arguments));

    in {
      lib = {
        setuptools = import ./setuptools.nix {
          inherit (nixpkgs) lib;
          parsec = nix-parsec.lib.parsec;
        };
      };
    } // systemDependent;
}
