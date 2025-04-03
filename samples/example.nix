# Run with 'nix-shell example.nix'
# Can use this as template for default.nix and just run new environments with 'nix-shell'

{ pkgs ? import <nixpkgs> {}, unstable ? import<nixos-unstable> {} }:

pkgs.mkShell {
  buildInputs = [
    unstable.deno # If newer versions are required prefix with 'unstable.'
    pkgs.nodejs_20 # Default to stable channel
  ];

  shellHook = 
  ''
    echo 'Deno version from unstable channel'
    deno --version

    echo ' '

    echo 'Node version from default stable channel'
    node --version
  '';
}
