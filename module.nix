{ lib }: rec {
  importFunction = f: if lib.isFunction f then f else import f;
  callFunctionWith = autoArguments: functionOrPath: arguments:
    let
      f = importFunction functionOrPath;
      functionArguments = lib.functionArgs f;
    in f
    (builtins.intersectAttrs functionArguments (autoArguments // arguments));
  makeModuleTree = autoArguments: module: arguments:
    let
      moduleUtilities = {
        makeModule = callFunctionWith (autoArguments // moduleUtilities);
      };
    in lib.fix
    (callFunctionWith (autoArguments // moduleUtilities) module arguments);
}
