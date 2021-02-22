{ parsec, lib }:

with parsec;
with lib;

let
  makeAttribute = name: value: { "${name}" = value; };
  mergeAttrSets = foldl (accu: element: accu // element) { };
  newline = string "\n";
  whitespace = string " ";
  pairKey = takeWhile1 (char: char != "\n" && char != "=" && char != " ");
  pairValue = takeWhile1 (char: char != "\n");
  valuePair = bind pairKey (name:
    skipThen (string " = ")
    (bind pairValue (value: pure (makeAttribute name value))));
  valueBlock = fmap mergeAttrSets (sepBy valuePair newline);
  sectionName = skipThen (string "[")
    (thenSkip (takeWhile1 (char: char != "]")) (string "]"));
  section = bind sectionName (name:
    skipThen (string "\n")
    (fmap (values: makeAttribute name values) valueBlock));
  setupCfg = fmap mergeAttrSets (sepBy section newline);
in { parseSetupCfg = configText: (runParser setupCfg configText).value; }
