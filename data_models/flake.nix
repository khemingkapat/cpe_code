{
  description = "Pure Nix Jupyter Environment with JupyterLab Vim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;


        # 🔹 Define Python environment including jupyterlab_vim
        pythonEnv = python.withPackages (ps: with ps;
          [
            numpy
            pandas
            matplotlib
            nbconvert
            jupyterlab
            (ps.buildPythonPackage rec {
              pname = "jupyterlab-vim";
              version = "4.1.4";
              pyproject = true;

              src = fetchPypi {
                pname = "jupyterlab_vim";
                inherit version;
                hash = "sha256-q/KJGq+zLwy5StmDIa5+vL4Mq+Uj042A1WnApQuFIlo=";
              };

              build-system = with pkgs; [
                hatch-nodejs-version
                hatchling
                jupyterlab
              ];

              dependencies = with pkgs; [
                hatch-jupyter-builder
                jupyterlab
              ];

              pythonImportsCheck = [
                "jupyterlab_vim"
              ];
            })
          ]);

      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            jupyter
            pandoc
            texlive.combined.scheme-full
          ];
          buildInputs = [ pythonEnv pkgs.nodejs ];

          shellHook = ''
            	  echo "✅ Setting up JupyterLab with Vim mode...
                  echo "✅ JupyterLab Vim is ready!"
          '';
        };
      });
}
