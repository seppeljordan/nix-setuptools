{ python, setuptools }:
self: {
  buildSetuptoolsPackage = { src, ... }@attrs:
    let
      parsedSetupCfg =
        setuptools.parseSetupCfg (builtins.readFile (src + "/setup.cfg"));
      pname = parsedSetupCfg.metadata.name;
      version = parsedSetupCfg.metadata.version;

    in python.pkgs.buildPythonPackage ({ inherit pname version; } // attrs);
}
