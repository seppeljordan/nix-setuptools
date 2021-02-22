{ setuptools, writeTextFile, lib }:

with builtins;
with lib;

let
  evaluateTestExpression = name: testExpression:
    writeTextFile {
      name = "testcase-${name}";
      text = toString testExpression;
    };
  makeTest = name: testExpression:
    nameValuePair "testcase-${name}"
    (evaluateTestExpression name testExpression);
  makeTests = mapAttrs' makeTest;

in makeTests {
  onlyMetadataName = let
    parsed = setuptools.parseSetupCfg ''
      [metadata]
      name = test-package
    '';
    expected = "test-package";
  in assert parsed.metadata.name == expected; true;

  metadataNameAndVersion = let
    parsed = setuptools.parseSetupCfg ''
      [metadata]
      name = test-package
      version = 1.0
    '';
    expected = "test-package";
  in assert parsed.metadata.name == expected; true;

  multipleSections = let
    parsed = setuptools.parseSetupCfg ''
      [metadata]
      name = test-package
      [options]
      test-option = 1
    '';
    expected = "test-package";
  in assert parsed.metadata.name == expected; true;
}
