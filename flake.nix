{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    flake-utils-plus,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
  in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;
      channels.nixpkgs = {
        config = {
          allowUnfree = true;
        };
        input = inputs.nixpkgs;
      };

      outputsBuilder = channels: let
        pkgs = channels.nixpkgs;
        inherit (pkgs) system;

        sources = pkgs.callPackage _sources/generated.nix {};

        commands =
          lib.mapAttrs
          (n: v: pkgs.writeShellScriptBin n v)
          {
            nvfetcher = ''
              set -euo pipefail
              KEY_FLAG=""
              [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
              [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
              export PATH=${pkgs.nix-prefetch-scripts}/bin:$PATH
              ${inputs.nvfetcher.packages."${system}".default}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o _sources "$@"
            '';
          };
      in rec {
        packages = {
          gcc-aarch64-linux-android = pkgs.callPackage pkgs/gcc-aarch64-linux-android.nix {};
          gcc-arm-linux-androideabi = pkgs.callPackage pkgs/gcc-arm-linux-androideabi.nix {};

          test = pkgs.callPackage ./pipeline {
            kernelDefconfigs = ["lineageos_karnak_defconfig"];
            kernelImageName = "Image.gz-dtb";
            kernelSrc = sources.linux-amazon-karnak.src;
            kernelPatches = [];
            oemBootImg = boot/amazon-fire-hd-karnak.img;
          };
        };

        formatter = pkgs.alejandra;

        apps = lib.mapAttrs (n: v: flake-utils.lib.mkApp {drv = v;}) commands;

        devShells.default = pkgs.mkShell {
          buildInputs = lib.mapAttrsToList (n: v: v) commands;
        };
      };
    };
}
