# Flake-Based Development Templates (Research / Python / ML)

This repository provides **Nix flake templates** for quickly bootstrapping reproducible development environments.

Instead of copying `flake.nix` files around, you can now **initialize new projects directly from this repo** using `nix flake init` -- just like official Nix templates.

---

## Requirements

### Install Nix

If you don’t already have Nix installed:

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Then enable flakes (if not already enabled):

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

---

## Using This Repo as a Template Source

This repository is structured as a **template registry**. Each subdirectory
represents a template that can be used with `nix flake init`.

Current templates:

```text
python/default
```

---

## Create a New Project

### Python Dev Environment

From any empty project directory, run:

```sh
nix flake init -t github:shahruk10/nixshells#python
```

Example:

```sh
mkdir my-ml-project
cd my-ml-project

nix flake init -t github:shahruk10/nixshells#python
```

This will generate:

```text
flake.nix
flake.lock
.envrc
```

If you have `direnv` installed (very much recommended), the `.envrc` file will
direct it to automatically activate the shell defined in the flake.nix with your
development environment.

There are multiple shells defined in the python template, one without CUDA support,
and one without. Enable which ever one you need. You can view the ones available
by running:

```sh
nix flake show
```

Each shell will automatically create a `.venv` directory and initialize a
virtual python environment there. You can install almost all python dependencies
via `pip` afterwards.

---

### Updating the Environment

To modify system packages:

1. Edit `flake.nix`
2. Add or remove packages from `buildInputs`
3. Reload the shell:

```sh
exit
nix develop
```

To update pinned dependencies:

```sh
nix flake update
```

---

## Resources

* Nix Flakes: [https://nixos.wiki/wiki/Flakes](https://nixos.wiki/wiki/Flakes)
* Nix Packages: [https://search.nixos.org/packages](https://search.nixos.org/packages)
* nixGL: [https://github.com/nix-community/nixGL](https://github.com/nix-community/nixGL)

---
