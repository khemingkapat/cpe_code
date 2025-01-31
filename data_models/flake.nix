{
  description = "Pure Nix Jupyter Environment with JupyterLab Vim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;

        # 🔹 Define Python environment including jupyterlab_vim
        pythonEnv = python.withPackages (
          ps: with ps; [
            numpy
            pandas
            matplotlib
            nbconvert
            jupyterlab
            self.packages.${system}.jupyterlab-vim
          ]
        );

      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            jupyter
            pandoc
            texlive.combined.scheme-full
          ];
          buildInputs = [
            pythonEnv
            pkgs.nodejs
          ];

          shellHook = ''
            	  echo "✅ Setting up JupyterLab with Vim mode..."
                  echo "✅ JupyterLab Vim is ready!"
          '';
        };

        packages = {
          jupyterlab-vim = pkgs.python311Packages.callPackage ./jupyterlab-vim.nix { };
        };
      }
    );
}
