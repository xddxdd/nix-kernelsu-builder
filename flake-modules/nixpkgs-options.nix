{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      # This sets `pkgs` to a nixpkgs with allowUnfree option set.
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    };
}
