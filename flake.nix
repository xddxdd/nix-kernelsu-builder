{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    let
      inherit (nixpkgs) lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/commands.nix
        ./flake-modules/nixpkgs-options.nix
        ./flake-modules/pre-commit-hooks.nix
        ./flake-modules/treefmt.nix
      ];

      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, ... }:
        let
          sources = pkgs.callPackage _sources/generated.nix { };
        in
        {
          packages = {
            gcc-aarch64-linux-android = pkgs.callPackage pkgs/gcc-aarch64-linux-android.nix { };
            gcc-arm-linux-androideabi = pkgs.callPackage pkgs/gcc-arm-linux-androideabi.nix { };
          } // (pkgs.callPackage ./kernels.nix { inherit sources; });
        };
    };
}
