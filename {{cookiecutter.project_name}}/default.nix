{ compiler ? "ghc822"
, pkgs ? null
}:

let
pkgs' = if pkgs == null
          then import ((import <nixpkgs> {}).fetchFromGitHub {
            owner = "NixOS"; repo = "nixpkgs";
            rev = "040a9ab240fba0b0dae5b48692fff7be50d3281c";
            sha256 = "0ganah2c7a4ankfxzc1lxn3bmfkk1g2sqrsab4j9pj5qzmjajq68";
          }) {}
        else pkgs;

haskellPackages = pkgs'.haskell.packages.${compiler}.override {
  overrides = se: su: {
    {{cookiecutter.project_name}} =
      se.callCabal2nix "{{cookiecutter.project_name}}" ./. {};
  };
};

prepareDev = se: drv:
  pkgs'.haskell.lib.addBuildDepends se.${drv} (
    pkgs'.lib.optionals pkgs'.lib.inNixShell [
      se.cabal-install
    ]
  );

addCompilerName = drv:
  drv.overrideAttrs (old: { name = "${old.name}-${compiler}"; });

in

addCompilerName (prepareDev haskellPackages "{{cookiecutter.project_name}}")
