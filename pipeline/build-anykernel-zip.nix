{
  stdenv,
  zip,
  callPackage,
  # User args
  arch,
  kernel,
  kernelImageName,
  ...
}: let
  sources = callPackage ../_sources/generated.nix {};
in
  stdenv.mkDerivation {
    name = "anykernel-zip";
    src = sources.kernelsu-anykernel3.src;

    nativeBuildInputs = [zip];

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
