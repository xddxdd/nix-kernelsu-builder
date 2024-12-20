{
  flake-parts-lib,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      pipeline = pkgs.callPackage ../pipeline { };

      kernelOptions = _: {
        options = {
          arch = lib.mkOption {
            type = lib.types.str;
            description = "Kernel architecture, usually `arm64`";
            default = "arm64";
          };
          anyKernelVariant = lib.mkOption {
            type = lib.types.enum [
              "osm0sis"
              "kernelsu"
            ];
            description = "Architecture of the kernel";
            default = "osm0sis";
          };
          clangVersion = lib.mkOption {
            type = lib.types.nullOr (lib.types.either lib.types.str lib.types.int);
            description = "Version of clang used in kernel build. Can be set to any version present in [nixpkgs](https://github.com/NixOS/nixpkgs). Currently the value can be 8 to 17. If set to `latest`, will use the latest clang in nixpkgs. If set to `null`, uses Google's GCC 4.9 toolchain instead.";
            default = null;
          };
          enableKernelSU = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to apply KernelSU patch";
            default = true;
          };
          kernelConfig = lib.mkOption {
            type = lib.types.lines;
            description = "Additional kernel config to be applied during build";
            default = "";
          };
          kernelDefconfigs = lib.mkOption {
            type = lib.types.nonEmptyListOf lib.types.str;
            description = "List of kernel config files applied during build";
          };
          kernelImageName = lib.mkOption {
            type = lib.types.str;
            description = "Generated kernel image name at end of compilation process";
            default = "Image";
          };
          kernelMakeFlags = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Additional make flags passed to kernel build process. Can be used to ignore some compiler warnings.";
            default = [ ];
          };
          kernelPatches = lib.mkOption {
            type = lib.types.listOf (lib.types.either lib.types.str lib.types.path);
            description = "List of patch files to be applied to kernel";
            default = [ ];
          };
          kernelSrc = lib.mkOption {
            type = lib.types.either lib.types.str lib.types.path;
            description = "Source code of the kernel";
          };
          oemBootImg = lib.mkOption {
            type = lib.types.nullOr (lib.types.either lib.types.str lib.types.path);
            description = "Optional, a working boot image for your device, either from official OS or a third party OS (like LineageOS). If this is provided, a `boot.img` will be generated, which can be directly flashed onto your device.";
            default = null;
          };
        };
      };
    in
    {
      options.kernelsu = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule kernelOptions);
        description = "Android kernels to be built with KernelSU";
        default = { };
      };

      config.packages = lib.mapAttrs (_k: pipeline) config.kernelsu;
    }
  );
}
