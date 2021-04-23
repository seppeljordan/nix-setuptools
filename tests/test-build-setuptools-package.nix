{ buildSetuptoolsPackage }:
self: {
  trivialPackage = buildSetuptoolsPackage { src = ./trivial-package; };
}
