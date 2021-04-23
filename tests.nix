{ lib, makeModule }:
self: {
  prefixNames = prefix:
    lib.mapAttrs' (name: value: lib.nameValuePair (prefix + "/" + name) value);
  parserTests =
    self.prefixNames "parserTests" (makeModule tests/test-parser.nix self);
}
