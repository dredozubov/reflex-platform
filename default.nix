let overrideCabal = drv: f: (drv.override (args: args // {
      mkDerivation = drv: args.mkDerivation (drv // f drv);
    })) // {
      overrideScope = scope: overrideCabal (drv.overrideScope scope) f;
    };
    nixpkgs = import ./nixpkgs {config.allowUnfree = true;};
    extendHaskellPackages = haskellPackages: haskellPackages.override {
      overrides = self: super: {
        reflex = self.callPackage ./reflex {};
        reflex-dom = self.callPackage ./reflex-dom {};
        reflex-todomvc = self.callPackage ./reflex-todomvc {};
        ghcjs-dom = overrideCabal super.ghcjs-dom (drv: {
          src = nixpkgs.fetchgit {
            url = git://github.com/xionite/ghcjs-dom.git;
            rev = "2d5a0aa64454f2c084b1a7c53cadb59b274d1386";
            sha256 = "8450b1a0de67cf6bb6c304c244e211331da8f5befdf92c089498c4394c14fcc2";
          };
        });
        active = overrideCabal super.active (drv: {
          version = "0.1.0.19";
          sha256 = "1zzzrjpfwxzf0zbz8vcnpfqi7djvrfxglhkvw1s6yj5gcblg2rcw";
          doCheck = false;
        });
        thyme = overrideCabal super.thyme (drv: {
          doCheck = false;
        });
        orgmode-parse = overrideCabal super.orgmode-parse (with self; drv: {
          version = "0.1.0.4";
          sha256 = "098zl8nyph459zyla0y2mkqiy78zp74yzadrnwa6xv07i5zs125h";
          buildDepends = [
            aeson attoparsec free hashable text thyme unordered-containers
          ];
          testDepends = [
            aeson attoparsec hashable HUnit tasty tasty-hunit text thyme
            unordered-containers
          ];
          doCheck = false;
        });
      };
    };
in rec {
  inherit nixpkgs;
  ghc = extendHaskellPackages nixpkgs.pkgs.haskell-ng.packages.ghc7101;
  ghcjs = extendHaskellPackages nixpkgs.pkgs.haskell-ng.packages.ghcjs;
  platforms = [ "ghcjs" ] ++ (if !nixpkgs.stdenv.isDarwin then [ "ghc" ] else []);
}
