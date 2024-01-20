{
  stdenv,
  android-tools,
  # User args
  arch,
  kernel,
  kernelImageName,
  bootImg,
  ...
}:
stdenv.mkDerivation {
  name = "boot-img";
  src = kernel;
  dontUnpack = true;

  nativeBuildInputs = [android-tools];

  buildPhase = ''
    runHook preBuild

    IMG_FORMAT=$(unpack_bootimg --boot_img ${bootImg} --format mkbootimg)
    echo "Image format: \"$IMG_FORMAT\""

    unpack_bootimg --boot_img ${bootImg}
    cp $src/arch/${arch}/boot/${kernelImageName} out/kernel

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    eval "mkbootimg $IMG_FORMAT -o $out/boot.img"

    runHook postInstall
  '';

  dontFixup = true;
}
