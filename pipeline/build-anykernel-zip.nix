{
  stdenv,
  lib,
  zip,
  callPackage,
  # User args
  arch,
  kernel,
  kernelImageName,
  variant,
  ...
}: let
  sources = callPackage ../_sources/generated.nix {};
in
  stdenv.mkDerivation {
    name = "anykernel-zip";
    src = sources."anykernel-${variant}".src;

    nativeBuildInputs = [zip];

    postPatch = lib.optionalString (variant == "osm0sis") ''
      sed -i 's/do.devicecheck=1/do.devicecheck=0/g' anykernel.sh
      sed -i 's!block=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;!block=auto;!g' anykernel.sh
      sed -i 's/is_slot_device=0;/is_slot_device=auto;/g' anykernel.sh
    '';

    buildPhase = ''
      runHook preBuild

      cp ${kernel}/arch/${arch}/boot/${kernelImageName} .
      if [ -f ${kernel}/arch/${arch}/boot/dtbo.img ]; then
        cp ${kernel}/arch/${arch}/boot/dtbo.img .
      fi

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      zip -r $out/anykernel.zip *

      runHook postInstall
    '';

    dontFixup = true;
  }
