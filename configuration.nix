# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{ config, lib, pkgs, ... }:
  let
    unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
    username = "christan"; # Use own username
    hostname = "chrisdevops"; # Use own hostname

    # Workaround to To open a new pane and tab on windows terminal using same pwd
    prompt_command = "\${PROMPT_COMMAND:+\"$PROMPT_COMMAND; \"}";
  in {

    # Using stable channel packages by default prefix with 'unstable.' 
    # for latest versions
    environment.systemPackages = with pkgs; [
      # Core Packages
      neovim
      gnumake
      busybox
      wget
      stern
      jq
      yq
      kubernetes-helm
      openssl
      go-task
      virtualenv
      kubectl
      kubectx
      kubelogin
      git
      azure-cli
      postgresql
      eksctl
      lazygit
      fd
      ripgrep
      chromium
      flyctl
      sops
      gnupg
      k9s
      ssm-session-manager-plugin
      awscli2
      docker_26
      docker-compose

      # LSP's for neovim
      terraform-ls
      terraform-lsp
      tflint
      yaml-language-server
      ansible-language-server
      ansible-lint
      lua-language-server
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      jdt-language-server

      dockerfile-language-server-nodejs
      pyright
      gopls
      nodePackages.typescript-language-server
      helm-ls
      nixd

      # Development
      terraform
      terragrunt
      python312Full
      python312Packages.ansible-core
      go
      nodejs_22
      typescript
      lua
      yarn

      # Other
      starship
      nushell
      glow
      nvidia-container-toolkit
      steampipe
    ];
  imports = [
    # Include NixOS-WSL modules
    <nixos-wsl/modules>

    # vscode integration https://github.com/nix-community/nixos-vscod?e-server
    (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
  ];

  # Licenced/Unfree/Broken Packages
  nixpkgs.config = {
    allowUnfree = false;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "terraform" "nvidia-x11" "nvidia-settings"
    ];
    allowBroken = false;
  };

  # Allow linked libraries
  programs.nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs; # Fix for vscode 24.05
      libraries = config.hardware.opengl.extraPackages;
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    daemon.settings.features.cdi = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings = {
        features.cdi = true;
        cdi-spec-dirs = ["/home/${username}/.cdi"];
      };
    };    
  };
  
  hardware = {
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = false;
    };
    nvidia = {
      open = true;
    };
  };

  services = {
    vscode-server = {
      enable = true;
    };
    xserver.videoDrivers = [ "nvidia" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users."${username}" = {
    extraGroups = [ "docker" ];
    shell = pkgs.nushell;
  };

  # Base WSL setup
  wsl = {
    enable = true;
    defaultUser = username;
    wslConf.network.hostname = hostname;
    wslConf.network.generateResolvConf = false;
    wslConf.boot.command = ""; #Default startup commands
    wslConf.user.default = username;
    useWindowsDriver = true;

    extraBin = with pkgs; [
      { src = "${coreutils}/bin/mkdir"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${coreutils}/bin/whoami"; }
      { src = "${coreutils}/bin/ls"; }
      { src = "${busybox}/bin/addgroup"; }
      { src = "${coreutils}/bin/uname"; }
      { src = "${coreutils}/bin/dirname"; }
      { src = "${coreutils}/bin/readlink"; }
      { src = "${coreutils}/bin/sed"; }

      #Allows .sh files to be run
      { src = "/run/current-system/sw/bin/sed"; }
      { src = "${su}/bin/groupadd"; }
      { src = "${su}/bin/usermod"; }
    ];
  };
  
  # DNS fix for WSL2
  networking.nameservers = ["8.8.8.8" "1.1.1.1"];

  # Set bash aliases and default editor
  environment.etc."bashrc".text = ''
    alias kc='kubectl'
    alias kctx='kubectx'
    alias kns='kubens'
    alias tf='terraform'
    alias tg='terragrunt'
    alias vi='nvim .'
    alias nixr='sudo nixos-rebuild switch'
    alias nixb='nixos-rebuild build'
    alias nixs='nix-shell'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias kcgp='kc get pods -l app.kubernetes.io/instance='
    alias kcgd='kc get deploy -l app.kubernetes.io/instance='
    alias kctp='kc top pods --containers -l app.kubernetes.io/instance='

    # Fix for ollama for neovim
    export XDG_RUNTIME_DIR="/tmp/"

    export EDITOR="nvim"
    export KUBE_CONFIG_PATH=~/.kube/config
    PROMPT_COMMAND=${prompt_command}'printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"'
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
