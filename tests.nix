{ lib }:
self:
let
  importTests = testModule:
    let
      module = self.makeModule testModule { };
      filterDerivations = lib.filterAttrs (name: value: lib.isDerivation value);
    in filterDerivations module;
in {
  prefixNames = prefix:
    lib.mapAttrs' (name: value: lib.nameValuePair (prefix + "/" + name) value);
  parserTests = importTests tests/test-parser.nix;
  buildSetuptoolsPackageTests =
    importTests tests/test-build-setuptools-package.nix;
  allTests = (self.prefixNames "parserTests" self.parserTests)
    // (self.prefixNames "buildSetuptoolsPackageTests"
      self.buildSetuptoolsPackageTests);
}
