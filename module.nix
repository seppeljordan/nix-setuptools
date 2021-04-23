{ lib }: rec {
  importFunction = f: if lib.isFunction f then f else import f;
  callFunctionWith = autoArguments: functionOrPath: arguments:
    let
      f = importFunction functionOrPath;
      functionArguments = lib.functionArgs f;
    in f
    (builtins.intersectAttrs functionArguments (autoArguments // arguments));
  makeModuleTree = autoArguments: module:
    let
      moduleFunction = callFunctionWith autoArguments module { };
      moduleWithUtilities = self:
        (moduleFunction self) // (moduleUtilities self);
      moduleUtilities = self: {
        makeModule = subModule: explicitArguments:
          makeModuleTree (autoArguments // self // explicitArguments) subModule;
      };
    in lib.fix moduleWithUtilities;
}
