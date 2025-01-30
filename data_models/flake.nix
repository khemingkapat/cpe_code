{
  description = "Jupyter Environment with NbExtensions (Fully Nix-Based)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;

        # jupyter-contrib-nbextensions = pythonPackages.buildPythonPackage rec {
        #   pname = "jupyter_contrib_nbextensions";
        #   version = "0.7.0";
        #   src = pkgs.fetchPypi {
        #     inherit pname version;
        #     sha256 = "06e33f005885eb92f89cbe82711e921278201298d08ab0d886d1ba09e8c3e9ca";
        #   };
        #   propagatedBuildInputs = with pythonPackages; [
        #     notebook 
        #     jupyter-contrib-core
        #     jupyter-nbextensions-configurator
        #     jupyter-highlight-selected-word
        #     ipython-genutils
        #   ];
        #   doCheck = false;
        # };
        # jupyterlab-vim = pkgs.python311Packages.buildPythonPackage rec {
        #   pname = "jupyterlab_vim"; # PyPI name uses underscore
        #   version = "4.14"; # Check for latest version
        #   src = pkgs.fetchPypi {
        #     inherit pname version;
        #     sha256 = "abf2891aafb32f0cb94ad98321ae7ebcbe0cabe523d38d80d569c0a50b85225a"; # Update if needed
        #   };
        #   propagatedBuildInputs = with pkgs.python311Packages; [
        #     jupyterlab
        #   ];
        #   doCheck = false;
        # };

        pythonEnv = python.withPackages (ps: with ps; [
          # notebook # ✅ Fix: Make sure Jupyter Notebook is installed
          numpy
          pandas
          matplotlib
          nbconvert
          jupyterlab-vim
          # jupyter-nbextensions-configurator
          # jupyter-contrib-nbextensions
          # jupyter-highlight-selected-word
          # ipython-genutils
          # lxml
        ]);

      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            jupyter
            pandoc
            texlive.combined.scheme-full
          ];
          buildInputs = [ pythonEnv ];

          shellHook = ''
            echo "✅ Jupyter environment is ready!"
            echo "Setting up Jupyter NbExtensions..."
          '';
        };
      });
}
