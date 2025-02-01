# NixOs Configuration for WSL - Quickstart

My custom NixOs configuration for WSL

## Setup and configure

Make sure the following is installed for this quickstart.

* WSL version 2
* vscode #optional

### 1.Install NixOs

Download the WSL distribution for NixOS follow reference link below.

Reference: https://nixos.wiki/wiki/WSL
Packages: https://search.nixos.org/packages

In Powershell run
* `wsl --update`
* `wsl --import NixOS .\NixOS\ nixos-wsl.tar.gz --version 2`
* `wsl -d NixOS`

### 2. Setup NixOs first install
* `sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable`
* `sudo nix-channel --update && sudo nixos-rebuild switch`
* `nix-env -iA nixos.neovim` # Optional step if you want to rename wsl username & hostname (or use own editor preference)
* `nix-env -iA nixos.git && nix-env -iA nixos.gnumake`

Clone the repo and edit variables if needed (change username and hostname)
Copy configuration.nix in /etc/nixos/configuration.nix and run `sudo nixos-rebuild boot` (Not switch as it may misconfigure on first setup)

Alternatively run using the included makefile.

* `sudo make boot`

On first install restart NixOs WSL distro on powershell

* `wsl -t NixOs`

Start a shell inside NixOS and immediately exit it to apply the new generation

* `wsl -d NixOS --user root exit`

Stop distro again

* `wsl -t NixOs`

Then can open again with default username applied and can continue as normal

### 3. Set NixOs as default WSL Distro
In Powershell run  
* `wsl -s NixOS`

### Notes

If you have changed the wsl default user you will need to reclone this in the new users home folder.

Known unstable items I am still trying to resolve.

* Sometimes first time switch fails on new installs, rerunning resolves the issue. 

See samples folder for configuration files for nix shell for dev environments

I have no idea how nix flakes work.

### WSL2 DNS fix

Set the following in your `.wslconf`

    [wsl2]
    networkingMode=mirrored
    dnsTunneling=false

### Getting docker to run with Nvidia containers
Reference: https://github.com/nix-community/NixOS-WSL/discussions/487
