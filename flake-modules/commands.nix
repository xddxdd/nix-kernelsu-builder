{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      inputs',
      ...
    }:
    let
      commands = rec {
        nvfetcher = ''
          set -euo pipefail
          KEY_FLAG=""
          [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
          [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
          export PATH=${pkgs.nix-prefetch-scripts}/bin:$PATH
          ${inputs'.nvfetcher.packages.default}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o _sources "$@"
        '';
      };
    in
    rec {
      apps = lib.mapAttrs (n: v: {
        type = "app";
        program = pkgs.writeShellScriptBin n v;
      }) commands;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = config.pre-commit.settings.enabledPackages ++ [
          config.pre-commit.settings.package
        ];
        shellHook = config.pre-commit.installationScript;

        buildInputs = lib.mapAttrsToList (
          n: _v:
          pkgs.writeShellScriptBin n ''
            exec nix run .#${n} -- "$@"
          ''
        ) apps;
      };
    };
}
