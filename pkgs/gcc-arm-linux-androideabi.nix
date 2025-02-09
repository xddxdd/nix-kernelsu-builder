{
  stdenv,
  lib,
  callPackage,
  autoPatchelfHook,
  python3,
}:
let
  sources = callPackage ../_sources/generated.nix { };
in
stdenv.mkDerivation {
  inherit (sources.gcc-arm-linux-androideabi) pname version src;

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
