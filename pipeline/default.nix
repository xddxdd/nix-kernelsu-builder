{
  lib,
  callPackage,
  runCommand,
  ...
}:
{
  arch,
  anyKernelVariant,
  clangVersion,
  kernelSU,
  kernelConfig,
  kernelDefconfigs,
  kernelImageName,
  kernelMakeFlags,
  kernelPatches,
  kernelSrc,
  oemBootImg,
  susfs,
}:
let
  pipeline = rec {
    patchedKernelSrc = callPackage ./patch-kernel-src.nix {
      inherit kernelSU susfs;
      src = kernelSrc;
      patches = kernelPatches;
    };

    kernelBuildClang = callPackage ./build-kernel-clang.nix {
      inherit
        arch
        clangVersion
        kernelSU
        susfs
        ;
      src = patchedKernelSrc;
      defconfigs = kernelDefconfigs;
      makeFlags = kernelMakeFlags;
      additionalKernelConfig = kernelConfig;
    };

    kernelBuildGcc = callPackage ./build-kernel-gcc.nix {
      inherit arch kernelSU susfs;
      src = patchedKernelSrc;
      defconfigs = kernelDefconfigs;
      makeFlags = kernelMakeFlags;
      additionalKernelConfig = kernelConfig;
    };

    kernelBuild = if clangVersion == null then kernelBuildGcc else kernelBuildClang;

    anykernelZip = callPackage ./build-anykernel-zip.nix {
      inherit arch kernelImageName;
      kernel = kernelBuild;
      variant = anyKernelVariant;
    };

    bootImg = callPackage ./build-boot-img.nix {
      inherit arch kernelImageName;
      bootImg = oemBootImg;
      kernel = kernelBuild;
    };
  };
in
runCommand "kernel-bundle" { passthru = pipeline; } (
  ''
    mkdir -p $out
    cp ${pipeline.kernelBuild}/arch/${arch}/boot/${kernelImageName} $out/
      if [ -f ${pipeline.kernelBuild}/arch/${arch}/boot/dtbo.img ]; then
        cp ${pipeline.kernelBuild}/arch/${arch}/boot/dtbo.img $out/
      fi
    cp ${pipeline.anykernelZip}/anykernel.zip $out/
  ''
  + (lib.optionalString (oemBootImg != null) ''
    cp ${pipeline.bootImg}/boot.img $out/
  '')
)
