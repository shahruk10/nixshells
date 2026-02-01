# Author: Shahruk Hossain <shahruk10@gmail.com>
# Year: 2022
#
# Common configuration and packages imported by other nix files.

{ pkgs ? import <nixpkgs> { config = { allowUnfree = true; }; }
, name ? "unnamed-shell" }: {
  buildInputs = with pkgs; [ git libtool libGL libsndfile ffmpeg_6-full mkl glib zlib ];

  shellHook = ''
    # Adding CC Lib, MKL, and zlib to top of LD_LIBRARY_PATH.
    export LD_LIBRARY_PATH=${pkgs.mkl}/lib:${pkgs.libsndfile.out}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib:${pkgs.ffmpeg_6-full.lib}/lib

    # Exporting ACLOCAL_PATH with libtool path included.
    export ACLOCAL_PATH=${pkgs.libtool}/share/aclocal:$ACLOCAL_PATH

    # Exporting environment variables for MKL.
    export MKLROOT=${pkgs.mkl}
    export MKLLIBDIR=${pkgs.mkl}/lib

    export name=${name}
  '';
}
