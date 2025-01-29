{
  description = "Jupyter Envrionment for Data Model";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for flakes
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311; # Choose your Python version
        pythonPackages = python.pkgs;
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            jupyter
            pandoc
            texlive.combined.scheme-full
          ];
          buildInputs = with pythonPackages; [
            numpy
            pandas
            matplotlib
            nbconvert
            jupyter-nbextensions-configurator
          ];
        };
      });
}
