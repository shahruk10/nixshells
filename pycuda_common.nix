# Author: Shahruk Hossain <shahruk10@gmail.com> Year: 2022
#
# Common nix file for creating a shell with Python and CUDA.
#
# Sets up appropriate python version, and CUDA if specified. Also installs and
# configures python virtualenv; python environments created within a specific
# nix-shell will be saved in its own directory under ~/.nixshells.

with import <nixpkgs> { config = { allowUnfree = true; }; };
with builtins;

{ python_version, gcc_version ? "9", cuda_version ? "no"
, cudnn_version ? "unknown" }:

let
  # Default name of the shell. May be overriden if importing file sets `name`.
  name = if cuda_version == "no" then
    "py${python_version}"
  else
    "py${python_version}-cuda${cuda_version}";

  # Common configuration.
  common = import ./common.nix {
    name = name;
    pkgs = pkgs;
  };

  # Path to append to LD_LIBRARY_PATH for gpu drivers on Non NixOS machinines.
  gpu_driver_libs = "/usr/lib/x86_64-linux-gnu";

  # Setting packages; evaluated lazily in mkShell.
  python = getAttr "python${python_version}" pkgs;
  gcc = getAttr "gcc${gcc_version}" pkgs;
  cuda = getAttr "cudatoolkit_${cuda_version}" pkgs;
  cudnn = getAttr "cudnn_${cudnn_version}_cudatoolkit_${cuda_version}" pkgs;
  cutensor = getAttr "cutensor_cudatoolkit_${cuda_version}" pkgs;

  patched_virtual_env_clone = python.pkgs.buildPythonPackage rec {
    pname = "virtualenv-clone";
    version = "0.5.7";
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "edwardgeorge";
      repo = pname;
      rev = version;
      hash = "sha256-qrN74IwLRqiVPxU8gVhdiM34yBmiS/5ot07uroYPDVw=";
    };

    postPatch = ''
      substituteInPlace tests/__init__.py \
        --replace "'virtualenv'" "'${python.pkgs.virtualenv}/bin/virtualenv'" \
        --replace "'3.9', '3.10']" "'3.9', '3.10', '3.11', '3.12']" # if the Python version used isn't in this list, tests fail

      substituteInPlace tests/test_virtualenv_sys.py \
        --replace "'virtualenv'" "'${python.pkgs.virtualenv}/bin/virtualenv'"

        substituteInPlace tests/test_virtualenv_clone.py \
        --replace "lines = f.read().decode('utf-8')" "# lines = f.read().decode('utf-8')"
    '';

    propagatedBuildInputs = [ python.pkgs.virtualenv ];

    meta = with lib; {
      homepage = "https://github.com/edwardgeorge/virtualenv-clone";
      description = "Script to clone virtualenvs";
      mainProgram = "virtualenv-clone";
      license = licenses.mit;
      maintainers = [ ];
    };
  };

  patched_virtualenv_wrapper = (python.pkgs.virtualenvwrapper.override {
    virtualenv-clone = patched_virtual_env_clone;
  });

  pythonPackages = with python.pkgs; [
    pip
    setuptools
    virtualenv
    patched_virtualenv_wrapper
    gcc
    espeak-phonemizer
  ];

  cudaPackages = [ cuda cudnn cutensor ];

  # Setting shell hooks; evaluated lazily in mkShell.
  pythonShellHook = ''
    # Adding executables to top of path.
    export PATH=${gcc}/bin:$PATH

    # virtualenv shell hooks.
    unset SOURCE_DATE_EPOCH
    export SHELL_DATA_DIR="$HOME/.nixshells/${name}"
    export WORKON_HOME=$SHELL_DATA_DIR/virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=${python.executable}
    source ${patched_virtualenv_wrapper}/bin/virtualenvwrapper.sh
  '';

  cudaShellHook = ''
    # Adding CUDA and cuDNN to top of LD_LIBRARY_PATH.
    export LD_LIBRARY_PATH=${cuda}/lib:${cuda.lib}/lib:${cudnn}/lib:$LD_LIBRARY_PATH

    # Exporting environment variables for CUDA directories.
    export CUDATKDIR=${cuda}

    # Need to include lib dir for graphics drivers on non NixOS machines.
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${gpu_driver_libs}
  '';

in mkShell {
  # If cuda_version is provided, include cuda packages.
  buildInputs = if cuda_version == "no" then
    pythonPackages ++ common.buildInputs
  else
    pythonPackages ++ cudaPackages ++ common.buildInputs;

  shellHook = if cuda_version == "no" then
    common.shellHook + pythonShellHook
  else
    common.shellHook + pythonShellHook + cudaShellHook;

  installPhase = ''
    # Patching python paths for previously created venvs incase the python
    # installation was gc-ed and no longer at the same path in the nix store as
    # it was when the venv was created.
    for e in $WORKON_HOME/*; do
      if [ ! -e $e/pyvenv.cfg ]; then
        continue
      fi

      sed -i \
        -e "s|home = .*|home = ${python}|g" \
        -e "s|base-prefix = .*|base-prefix = ${python}|g" \
        -e "s|base-exec-prefix = .*|base-exec-prefix = ${python}|g" \
        -e "s|base-executable = .*|base-executable = ${python}/bin/${python.executable}|g" \
        $e/pyvenv.cfg
    done
  '';
}
