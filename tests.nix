{ lib }:
self: {
  importTests = testModule:
    let
      module = self.makeModule testModule;
      filterDerivations = lib.filterAttrs (name: value: lib.isDerivation value);
    in filterDerivations module;
  prefixNames = prefix:
    lib.mapAttrs' (name: value: lib.nameValuePair (prefix + "/" + name) value);
  parserTests = self.importTests tests/test-parser.nix;
  allTests = self.prefixNames "parserTests" self.parserTests;
}
