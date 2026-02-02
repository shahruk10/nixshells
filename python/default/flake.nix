# Author: Shahruk Hossain <shahruk10@gmail.com>
# Year: 2026
#
# Nix Flake for Python (CPU + CUDA) dev environment..

{
  description = "Python (CPU + CUDA) dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-gl-host.url = "github:numtide/nix-gl-host";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-gl-host,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        mkPythonShell =
          {
            python,
            cudaPackages ? null,
            ...
          }:
          let
            useCuda = cudaPackages != null;

            name =
              "py${python.version}" + pkgs.lib.optionalString useCuda "-cuda${cudaPackages.cudatoolkit.version}";

            buildInputs =
              with pkgs;
              [
                python
                git
                gcc
                libtool
                libGL
                libsndfile
                ffmpeg_6-full
                mkl
                glib
                zlib
                espeak-ng
              ]
              ++ pkgs.lib.optionals useCuda [
                cudaPackages.cudatoolkit
                cudaPackages.cudnn
                nix-gl-host.defaultPackage.${system}
              ];

            shellHook = ''
              export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.mkl}/lib:${pkgs.libsndfile.out}/lib:${pkgs.zlib}/lib:${pkgs.ffmpeg_6-full.lib}/lib:$LD_LIBRARY_PATH

              export MKLROOT=${pkgs.mkl}
              export MKLLIBDIR=${pkgs.mkl}/lib

              export ACLOCAL_PATH=${pkgs.libtool}/share/aclocal:$ACLOCAL_PATH

              # -----------------------------
              # PROJECT-LOCAL VENV
              # -----------------------------

              if [ ! -d .venv ]; then
                echo "📦 Creating virtualenv"
                ${python}/bin/python -m venv --symlinks .venv
              fi

              source .venv/bin/activate
              export VIRTUAL_ENV_DISABLE_PROMPT=1
              export PS1="(venv) $PS1"
            ''
            + pkgs.lib.optionalString useCuda ''
              export CUDATKDIR=${cudaPackages.cudatoolkit}
              export LD_LIBRARY_PATH=${cudaPackages.cudatoolkit}/lib:$LD_LIBRARY_PATH
            '';
          in
          pkgs.mkShell {
            inherit name buildInputs shellHook;
          };
      in
      {
        devShells = {
          default = mkPythonShell {
            python = pkgs.python311;
          };
          cuda = mkPythonShell {
            python = pkgs.python311;
            cudaPackages = pkgs.cudaPackages;
          };
          cuda126 = mkPythonShell {
            python = pkgs.python311;
            cudaPackages = pkgs.cudaPackages_12_6;
          };
        };
      }
    );
}
