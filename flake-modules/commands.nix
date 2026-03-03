_: {
  perSystem =
    { pkgs, ... }:
    {
      commands = {
        nvfetcher = ''
          set -euo pipefail
          KEY_FLAG=""
          [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
          [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
          export PATH=${pkgs.nix-prefetch-scripts}/bin:$PATH
          ${pkgs.nvfetcher}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o _sources "$@"
        '';
      };
    };
}
