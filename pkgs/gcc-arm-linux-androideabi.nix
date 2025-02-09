{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "gcc-arm-linux-androideabi";
  version = "12.1.0_r27";
  src = fetchzip {
    url = "https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/refs/tags/android-${version}.tar.gz";
    sha256 = "sha256-UFwNVvke6qcwPyOAx+z0XAEgzVQRwv3+XF5v4qisp6o=";
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
    description = "ARM32 GCC for building Android kernels";
    platforms = [ "x86_64-linux" ];
  };
}
