{
  description = "Search Algorithm with Julia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      # You can change this to "aarch64-darwin" if you are on an Apple Silicon Mac
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        # Add only Julia here
        packages = [
          pkgs.julia-bin
        ];

        shellHook = ''
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          echo "Julia environment loaded!"
          rj() {
            if [[ -f "Project.toml" ]]; then
              echo "Activating project environment from current directory..."
              julia --project=. "$@"
            elif [[ -f "../Project.toml" ]]; then
              echo "Activating project environment from parent directory..."
              julia --project=.. "$@"
            else
              echo "No Project.toml found. Running Julia normally..."
              julia "$@"
            fi
          }
        '';
      };
    };
}
