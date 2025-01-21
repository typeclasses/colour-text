{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ self, ... }:
    let packageName = "colour-text";
    in inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        project = pkgs.haskellPackages.developPackage {
          root = ./colour-text;
          name = packageName;
        };
        inherit (pkgs.lib) fold composeExtensions concatMap attrValues;

        combineOverrides = old:
          fold composeExtensions (old.overrides or (_: _: { }));

      in {
        defaultPackage = self.packages.${system}.${packageName};

        packages = let

          inherit (pkgs.haskell.lib) dontCheck;

          makeTestConfiguration = let defaultPkgs = pkgs;
          in { pkgs ? defaultPkgs, ghcVersion, overrides ? new: old: { } }:
          let inherit (pkgs.haskell.lib) dontCheck packageSourceOverrides;
          in (pkgs.haskell.packages.${ghcVersion}.override (old: {
            overrides = combineOverrides old [
              (packageSourceOverrides { colour-text = ./colour-text; })
              (new: old: { })
              overrides
            ];

          })).colour-text;

        in rec {
          "${packageName}" = project;

          ghc-9-6 = makeTestConfiguration { ghcVersion = "ghc96"; };
          ghc-9-8 = makeTestConfiguration { ghcVersion = "ghc98"; };
          all = pkgs.symlinkJoin {
            name = packageName;
            paths = [ ghc-9-6 ghc-9-8 ];
          };
        };
      });
}
