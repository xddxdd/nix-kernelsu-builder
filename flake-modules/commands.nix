_: {
  perSystem = { pkgs, inputs', ... }: {
    commands = {
      nvfetcher = ''
        set -euo pipefail
        KEY_FLAG=""
        [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
        [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
        export PATH=${pkgs.nix-prefetch-scripts}/bin:$PATH
        ${inputs'.nvfetcher.packages.default}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o _sources "$@"
      '';
    };
  };
}
