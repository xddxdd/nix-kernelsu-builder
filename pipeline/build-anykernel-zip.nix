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
}:
let
  sources = callPackage ../_sources/generated.nix { };
in
stdenv.mkDerivation {
  name = "anykernel-zip";
  inherit (sources."anykernel-${variant}") src;

  nativeBuildInputs = [ zip ];

  postPatch = lib.optionalString (variant == "osm0sis") ''
    substituteInPlace anykernel.sh \
      --replace-fail "do.devicecheck=1" "do.devicecheck=0" \
      --replace-fail "BLOCK=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;" "BLOCK=auto;" \
      --replace-fail "IS_SLOT_DEVICE=0;" "IS_SLOT_DEVICE=auto;"
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
