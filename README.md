# Nix-based KernelSU Android Boot Image Builder

A set of nix packages (derivations) to build Android `boot.img` and AnyKernel installation zip files for given kernel source code.

# Packages

Currently I build boot images for 3 devices:

- `.#amazon-fire-hd-karnak`: Amazon Fire HD 8 2018. Kernel compiles, but KernelSU doesn't work for lack of 32-bit userland app.
- `.#moto-rtwo-lineageos-21`: Motorola Edge+ 2023, unofficial LineageOS 21. Working perfectly.
- `.#oneplus-8t-blu-spark`: OnePlus 8T, Blu_spark kernel for LineageOS 21. Working perfectly.

# How to add my own device

See `kernels.nix` for definitions of pipelines (builds for different devices).

Each kernel definition takes these arguments:

- `arch`: Kernel architecture, usually `arm64`.
- `anyKernelVariant`: Variant of AnyKernel used during packaging. Can have two values:
  - `osm0sis`: [Official version](https://github.com/osm0sis/AnyKernel3). Works with devices before Android Generic Kernel Image (GKI).
  - `kernelsu`: [Modified by KernelSU team](https://github.com/Kernel-SU/AnyKernel3). Works with devices using GKI.
- `clangVersion`: Version of clang used in kernel build.

  - Can be set to any version present in [nixpkgs](https://github.com/NixOS/nixpkgs). Currently the value can be 8 to 17.
  - If set to `latest`, will use the latest clang in nixpkgs. Recommended.
  - If set to `null`, uses Google's GCC 4.9 toolchain instead.

- `kernelSU.enable`: Whether to apply KernelSU patch.
- `kernelSU.variant`: Variant of KernelSU to use. Can be [`official`](https://github.com/tiann/KernelSU), [`next`](https://github.com/rifsxd/KernelSU-Next) or `custom`.
- `kernelSU.src`: If `kernelSU.variant` is `custom`, specify the source of KernelSU patches.
- `kernelSU.revision`: If `kernelSU.variant` is `custom`, specify the revision number of KernelSU patches.
- `kernelSU.subdirectory`: If `kernelSU.variant` is `custom`, specify the directory where KernelSU patches will be extracted to.

- `susfs.enable`: Whether to apply [SusFS patch](https://gitlab.com/simonpunk/susfs4ksu).
- `susfs.src`: Source of SusFS patches. Since SusFS has too many different branches, we do not provide default variants.
- `susfs.kernelPatch`: Path to SusFS's kernel patch. If set, will override the patch used. Useful for overriding patch to adapt to different kernel versions.
- `susfs.kernelsuPatch`: Path to SusFS's KernelSU patch. If set, will override the patch used. Used for overriding patch to adapt to different KernelSU versions.

- `kernelConfig`: Additional kernel config to be applied during build.
- `kernelDefconfigs`: List of kernel config files applied during build.
  - Older kernels usually have a single `_defconfig` file. Newer devices may have several.
  - If you're building for a open source third party ROM, check the `android_device_[Codename of your device]` repo and `android_device_[Codename of your device]_common` repo, take a look at the `BoardConfig.mk` and `BoardConfigCommon.mk`, and take note of all config files in `TARGET_KERNEL_CONFIG` variable.
  - If you do not have access to such repos, you will need to do some guesswork.
- `kernelImageName`: Generated kernel image name at end of compilation process. Usually `Image`. If you are unsure, again check the `BoardConfig.mk` or `BoardConfigCommon.mk`, and look for `BOARD_KERNEL_IMAGE_NAME`.
- `kernelMakeFlags`: Additional make flags passed to kernel build process. Can be used to ignore some compiler warnings.
- `kernelPatches`: List of patch files to be applied to kernel.
- `kernelSrc`: Source code of the kernel. Can be supplied with `fetchgit`, `fetchGitHub` or alike, or provided with [nvfetcher](https://github.com/berberman/nvfetcher), which is already set up in this repo.
- `oemBootImg`: Optional, a working boot image for your device, either from official OS or a third party OS (like LineageOS). If this is provided, a `boot.img` will be generated, which can be directly flashed onto your device.

# Use as Flake.parts module

If you want to build Android kernels in your own flake, you can import this repo as a [Flake.parts](https://flake.parts/) module:

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-kernelsu-builder.url = "github:xddxdd/nix-kernelsu-builder";
  };
  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nix-kernelsu-builder.flakeModules.default
      ];
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, ... }:
        {
          kernelsu = {
            # Add your own kernel definition here
            example-kernel = {
              anyKernelVariant = "kernelsu";
              clangVersion = "latest";

              kernelSU.variant = "next";
              susfs = {
                enable = true;
                src = path/to/sufs/source;
                kernelsuPatch = ./patches/susfs-for-kernelsu-next.patch;
              };

              kernelDefconfigs = [
                "gki_defconfig"
                "vendor/kalama_GKI.config"
                "vendor/ext_config/moto-kalama.config"
                "vendor/ext_config/moto-kalama-gki.config"
                "vendor/ext_config/moto-kalama-rtwo.config"
              ];
              kernelImageName = "Image";
              kernelMakeFlags = [
                "KCFLAGS=\"-w\""
                "KCPPFLAGS=\"-w\""
              ];
              kernelSrc = path/to/kernel/source;
            };
          };
        };
    };
}
```

# License

GPLv3.
