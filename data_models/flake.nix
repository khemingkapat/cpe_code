{
  description = "Jupyter Environment with JupyterLab Vim (Fully Nix-Based)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;

        # Γ£à Define Python environment with required packages
        pythonEnv = python.withPackages (ps: with ps; [
          numpy
          pandas
          matplotlib
          nbconvert
          jupyterlab
          pip
          jupyterlab-lsp
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
                                    echo "⌛ Setting up JupyterLab with Vim mode..."
                        	    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"

                                    export VENV_DIR=".venv"
                                    if [ ! -d "$VENV_DIR" ]; then
                                      python -m venv $VENV_DIR
                                      source $VENV_DIR/bin/activate
                                      pip install --no-cache-dir jupyterlab_vim
            			  pip install --no-cache-dir 'python-lsp-server[all]'
                                    else
                                      source $VENV_DIR/bin/activate
                                    fi

                                    echo "✅ JupyterLab Vim is ready!"
          '';
        };
      });
}
