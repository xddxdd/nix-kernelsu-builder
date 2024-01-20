{
  stdenv,
  lib,
  callPackage,
  writeShellScriptBin,
  git,
  coreutils,
  # User args
  src,
  patches,
  enableKernelSU,
  ...
}: let
  sources = callPackage ../_sources/generated.nix {};

  fakeGit = writeShellScriptBin "git" ''
    exit 0
  '';
in
  stdenv.mkDerivation {
    name = "patched-kernel";
    inherit src patches;

    nativeBuildInputs = [fakeGit coreutils];

    postPatch =
      (lib.optionalString enableKernelSU ''
        export HOME=$(pwd)

        pushd ${sources.kernelsu-stable.src}
        ${git}/bin/git config --global --add safe.directory ${sources.kernelsu-stable.src}
        KSU_GIT_VERSION=$(${git}/bin/git rev-list --count HEAD)
        KSU_VERSION=$(expr 10000 + $KSU_GIT_VERSION + 200)
        echo "KernelSU Version: $KSU_VERSION / $KSU_GIT_VERSION"
        popd

        cp -r ${sources.kernelsu-stable.src} KernelSU
        chmod -R +w KernelSU
        # Force set KernelSU version
        sed -i "/KernelSU version:/d" KernelSU/kernel/Makefile
        sed -i "/KSU_GIT_VERSION not defined/d" KernelSU/kernel/Makefile
        sed -i "s|ccflags-y += -DKSU_VERSION=|ccflags-y += -DKSU_VERSION=$KSU_VERSION\n#|g" KernelSU/kernel/Makefile
      '')
      + ''
        patchShebangs .
      ''
      + (lib.optionalString enableKernelSU ''
        bash KernelSU/kernel/setup.sh
      '')
      + ''
        sed -i "s|/bin/||g" Makefile
      '';

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r * $out/

      runHook postInstall
    '';

    dontFixup = true;
  }
