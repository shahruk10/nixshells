# Author: Shahruk Hossain <shahruk10@gmail.com>
# Year: 2022
#
# Common configuration and packages imported by other nix files.

{ pkgs ? import <nixpkgs> { config = { allowUnfree = true; }; }
, name ? "unnamed-shell" }: {
  buildInputs = with pkgs; [ git libtool libGL mkl glib zlib ];

  shellHook = ''
    # Adding CC Lib, MKL, and zlib to top of LD_LIBRARY_PATH.
    export LD_LIBRARY_PATH=${pkgs.mkl}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH

    # Exporting ACLOCAL_PATH with libtool path included.
    export ACLOCAL_PATH=${pkgs.libtool}/share/aclocal:$ACLOCAL_PATH

    # Exporting environment variables for MKL.
    export MKLROOT=${pkgs.mkl}
    export MKLLIBDIR=${pkgs.mkl}/lib

    # Prompt Appearance. Appends nix-shell name to the front.
    resetcolor="\033[00m"
    cyan="\033[1;36m"
    blue="\033[1;34m"
    green1="\033[0;32m"
    green2="\033[1;32m"

    export PS1="\[$cyan\](${name})\[$resetcolor\] \[$green2\]\u@\h\[$resetcolor\]:\[$blue\]\w\[$resetcolor\]\[$green1\]$(__git_ps1 " (%s)")\[$resetcolor\]\$ "
  '';
}
