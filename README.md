# nix-setuptools

This flake want to provide handy tools for working with python
packages that use setuptools.

Currently it includes a rudimentary parser for "setup.cfg" and
shorthand for packaging setuptools packages with nixpkgs.

# parser

The parser only understands the basic syntax of setuptools probably
only works for a subset of the setup.cfg specification. Inside the
flake it is located at ``lib.setuptools.parseSetupCfg``.

Check out the tests in ``tests/test-parser.nix`` to see all supported
features of the parser in action.

# packaging

The packaging utilities are located at ``lib.packaging``.  Note that
this is a function that needs to be called with the desired python
implementation.  The following code snippet builds a trivial testing
package from inside this flake.  Not that this package does not have
any dependencies and can therefore instatiate as a derivation
directly.

```nix
with builtins;
let
  flake = getFlake("github:seppeljordan/nix-setuptools");
  nixpkgs = getFlake("github:NixOS/nixpkgs-channels/nixpkgs-unstable");
  python = nixpkgs.legacyPackages."${currentSystem}".python;
  packaging = flake.lib.packaging { inherit python; };
in packaging.buildSetuptoolsPackage {
  src = flake + "/tests/trivial-package";
}
```

A more involved usecase would be to use the ``buildSetuptoolsPackage``
function when extending the python packages provided by nixpkgs.

TODO: provide example for this usecase preferably inside an
integration test.
