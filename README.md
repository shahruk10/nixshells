# Virtual Environments for System Packages with `nix-shell`

- [`nix-shell`](https://nixos.wiki/wiki/Development_environment_with_nix-shell)
  is a package manager that lets you:
  
  - Use a package without installing it globally.

  - Create isolated, reproducible virtual environments with any packages you
  require without causing bunch of version conflicts - *think python `venv` but
  for system packages* (but it's so much more).

  ![Python virtual environments inside `nix-shells`](./.images/overview.png)

- This blog by Mattia Gheda has a [good introduction](https://ghedam.at/15978/an-introduction-to-nix-shell).
  to `nix-shell`.

- I have switched to using `nix-shell` for all my development needs. This
  repository contains nix files I use quite frequently when working with Python
  and CUDA, as well as other development languages and tools.

---

## Installing `nix-shell`

- `nix-shell` can be installed on both linux and macOS using the following
  command (follow on screen instructions):

  ```sh
  sh <(curl -L https://nixos.org/nix/install) --daemon
  ```

---

## Example Usage

- Assuming you have `nix-shell` installed, you can create environments with
  python and CUDA by invoking `nix-shell` with the appropriate `.nix` file.

- There are several in the repo with different combinations of python and CUDA
  versions.

- For example, for `python 3.8` with `CUDA 11.3` and cuDNN use `py38cuda113.nix`
  like so:

  ```sh
  # The location of this repository.
  REPO=/home/$USER/nixshells

  # Python 3.8 with CUDA 11.3 and CuDNN.
  #
  # After this command completes, you will be prompted with a new shell
  # with python v3.8.x and CUDA installed. When used the for the first time,
  # it will download python and CUDA files from the Nix package manager to your
  # local nixstore. Subsequent invocations will use downloaded files.
  #
  # CUDA and cuDNN is a big download (~4 GB), so the first invocation will take
  # a while depending on your internet speed.
  nix-shell ${REPO}/py38cuda113.nix
  ```

- This environment comes with `python 3.8`,
  [`virtualenvwrapper`](https://virtualenvwrapper.readthedocs.io/en/latest/) and
  `CUDA 11.3` installed. You can now create a python virtual environment the
  usual way of using `virtualenvwrapper` by running:

  ```sh
  # Will create a virutal environment called `tf28` under ~/.nixshells/py38-cuda113
  # and enable it. Different .nix files will have a different directory for storing
  # python virtual environments.
  mkvirutalenv tf28
  ```

- Install any packages you want in the python environment (which is now active
  inside the nix-shell):

  ```sh
  # Installing tensorflow.
  pip install tensorflow==2.8.0
  
  # Check if CUDA is available.
  python -c 'import tensorflow as tf; print(tf.test.is_gpu_available())'
  ```

- To deactivate the `virtualenv` and nix shell, press `Ctrl + D`. Your python
  environments will be preserved and be accessible you re-activate the nix shell
  again.

---

## Updating Packages

- To use different python or CUDA versions, you can pretty much duplicate one of the
  [`py.*cuda.*.nix`](./py38cuda113.nix#L7) files and update the build parameters.
  
- The nix files are *relatively* straight forward, and you can add / remove
  packages you want by updating the `buildInputs` argument in the [common.nix
  file](./common.nix#8). The package list here is shared with all other `.nix`
  files in the repository.
  
- To search through the the 80,000+ available packages, check
  [https://search.nixos.org/packages](https://search.nixos.org/packages).

- Of course you can create your own nix files too :D

  - This blog by Mattia Gheda has a [good introduction](https://ghedam.at/15978/an-introduction-to-nix-shell).

  - The [official wiki](https://nixos.wiki/wiki/Python) can be a bit
    intimidating for newbies but is an excellent resource nonetheless.

  - More about Nix and NixOS [here](https://ghedam.at/15490/so-tell-me-about-nix).
