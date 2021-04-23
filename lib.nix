{ }:
self: {
  setuptools = self.makeModule lib/setuptools.nix { };
  packaging = { python }: self.makeModule lib/packaging.nix { inherit python; };
}
