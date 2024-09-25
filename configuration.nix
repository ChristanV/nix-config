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

      # Core Development Packages
      awscli2
      python312Packages.ansible-core
      virtualenv
      kubectl
      kubectx
      kubelogin
      git
      azure-cli
      terraform
      python3
      postgresql
      eksctl
      lazygit

      # LSP's for neovim
      terraform-ls
      tflint
      yaml-language-server
      ansible-language-server
      ansible-lint
      lua-language-server
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      java-language-server
      dockerfile-language-server-nodejs
      pyright
      gopls
      nodePackages.typescript-language-server

      # Other
      fd
      ripgrep
      chromium
      flyctl
      sops
      gnupg
      podman

      # Development
      go
      nodejs_22
      typescript
    ];
  imports = [
    # Include NixOS-WSL modules
    <nixos-wsl/modules>

    # vscode integration https://github.com/nix-community/nixos-vscode-server
    (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
  ];
  
  # Licenced Packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "terraform"
  ];

  services.vscode-server.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Base WSL setup
  wsl = {
    enable = true;
    defaultUser = username;
    wslConf.network.hostname = hostname;
    wslConf.network.generateResolvConf = false;
    wslConf.boot.command = ""; #Default startup commands
    wslConf.user.default = username;

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
  
  networking.nameservers = ["8.8.8.8" "1.1.1.1"];

  # Set bash aliases and default editor
  environment.etc."bashrc".text = ''
    alias kc='kubectl'
    alias kctx='kubectx'
    alias kns='kubens'
    alias tf='terraform'
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
    export EDITOR="nvim"
    export KUBE_CONFIG_PATH=~/.kube/config
    export PODMAN_IGNORE_CGROUPSV1_WARNING=true
    PROMPT_COMMAND=${prompt_command}'printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"'
  '';

  # Setup podman
  environment.etc."containers/registries.conf" = {
    text = ''
      unqualified-search-registries = ["docker.io"]
    '';
  };

  environment.etc."containers/policy.json" = {
    text = ''
      {
        "default": [{
            "type": "insecureAcceptAnything"
          }],
        "transports":{
            "docker-daemon":{
                "": [{"type":"insecureAcceptAnything"}]
            }
         }
      }
    '';
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
