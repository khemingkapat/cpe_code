{
  description = "Nix-based JupyterLab with Python";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;

        pythonEnv = python.withPackages (ps: with ps; [
          numpy
          pandas
          matplotlib
          nbconvert
          jupyterlab
          ipykernel
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
            echo "🔹 Activating JupyterLab environment..."

            # Ensure Jupyter uses the correct Python
            export PATH="${pythonEnv}/bin:$PATH"

            # Register the kernel
            ${pythonEnv}/bin/python -m ipykernel install --user --name "nix-python" --display-name "Python (Nix)"

            echo "✅ Jupyter Kernel Registered: Python (Nix)"
          '';
        };
      });
}
