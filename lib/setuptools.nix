{ parsec, lib }:
self:

with parsec;
with lib;
with builtins;

let
  makeAttribute = name: value: { "${name}" = value; };
  mergeAttrSets = foldl (accu: element: accu // element) { };
  newlinePlusEmptyLines = sequence_ [ newline (many emptyLine) ];
  emptyLine = sequence_ [ (many whitespace) newline ];
  newline = string "\n";
  whitespace = string " ";
  keyValueSeparator =
    sequence_ [ (many whitespace) (string "=") (many whitespace) ];
  strip = text:
    let
      unfilteredTokens = split " " text;
      tokens = filter (token: token != [ ] && token != "") unfilteredTokens;
    in concatStringsSep " " tokens;
  pairKey = takeWhile1 (char: char != "\n" && char != "=" && char != " ");
  pairValue = choice [ multiLineValue singleLineValue ];
  singleLineValue = takeWhile1 (char: char != "\n");
  multiLineValue = fmap (elems: map strip elems) (skipThen newline
    (sepBy singleLineValue (sequence_ [ newline (many1 whitespace) ])));
  valuePair = bind pairKey (name:
    skipThen keyValueSeparator
    (bind pairValue (value: pure (makeAttribute name value))));
  valueBlock = fmap mergeAttrSets (sepBy valuePair newlinePlusEmptyLines);
  sectionName = skipThen (string "[")
    (thenSkip (takeWhile1 (char: char != "]")) (string "]"));
  section = bind sectionName (name:
    skipThen newlinePlusEmptyLines
    (fmap (values: makeAttribute name values) valueBlock));
  sectionSeperator = newlinePlusEmptyLines;
  setupCfg = fmap mergeAttrSets (sepBy section sectionSeperator);
in { parseSetupCfg = configText: (runParser setupCfg configText).value; }
