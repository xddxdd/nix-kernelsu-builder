{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "gcc-aarch64-linux-andriod";
  version = "12.1.0_r27";
  src = fetchzip {
    url = "https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/refs/tags/android-${version}.tar.gz";
    sha256 = "sha256-4SRSCwbRIFEff+Aj9XRnjCNruuUxgV3SB1mnyLeH4yk=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    license = lib.licenses.gpl3Plus;
    description = "ARM64 GCC for building Android kernels";
    platforms = [ "x86_64-linux" ];
  };
}
