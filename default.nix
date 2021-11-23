{ arch ? "AMD64", lib ? (import <nixpkgs> { }).lib }:
let
  sources = import ./sources.nix;
  system = builtins.currentSystem;
  utility =  import ./utility.nix { inherit arch lib sources; };
in with sources; rec {
  boot-tools = import ./packages/boot-tools { inherit system arch lib sources utility; };
  extra-tools = import ./packages/extra-tools { inherit system sources utility boot-tools; };
}
