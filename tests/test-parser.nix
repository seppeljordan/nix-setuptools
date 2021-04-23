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
  in assert parsed.metadata.name == "test-package";
  assert parsed.options.test-option == "1";
  true;

  multipleSectionsWithNewlines = let
    parsed = setuptools.parseSetupCfg ''
      [metadata]
      name = test-package


      [options]
      test-option = 1
    '';
  in assert parsed.metadata.name == "test-package";
  assert parsed.options.test-option == "1";
  true;

  emptyLinesInSection = let
    parsed = setuptools.parseSetupCfg ''
      [metadata]

      name = test-package

      version = 1
    '';
  in assert parsed.metadata.name == "test-package";
  assert parsed.metadata.version == "1";
  true;

  whitespaceLinesBetweenSections = let
    # we use an @ that we replace with an empty space to deal with
    # editors that nuke whitespaces at the end of lines when saving a
    # file.
    text = replaceStrings [ "@" ] [ " " ] ''
      [metadata]
      name = test-package
        @

      [options]
      test-option = 1
    '';
    parsed = setuptools.parseSetupCfg text;
  in assert parsed.metadata.name == "test-package";
  assert parsed.options.test-option == "1";
  true;

  multilineOptions = let
    parsed = setuptools.parseSetupCfg ''
      [section]
      multi-line-option =
          line1
          line2
    '';
  in assert parsed.section.multi-line-option == [ "line1" "line2" ]; true;

  multilineOptionsMixedWithSingleLineOptions = let
    parsed = setuptools.parseSetupCfg ''
      [section]
      multi-line-option =
          line1
          line2
      single-line-option = 1
    '';
  in assert parsed.section.multi-line-option == [ "line1" "line2" ];
  assert parsed.section.single-line-option == "1";
  true;
}
