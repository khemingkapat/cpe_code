{
  description = "Text Analytics Course Works";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          uv
          python311
          # System libraries needed by pre-compiled Python wheels
          stdenv.cc.cc.lib
          zlib
        ];

        env = {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
          ];
        };

        shellHook = ''
          echo "Text Analytics Course Works"
          echo "Run 'uv sync' to install dependencies"
          echo "Run 'uv run jupyter lab' to start"

          export SHELL=/home/khemi/.nix-profile/bin/zsh
          exec /home/khemi/.nix-profile/bin/zsh
        '';
      };
    };
}
