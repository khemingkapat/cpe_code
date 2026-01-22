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

                    # Custom function to run Julia with the local project automatically
                    rj() {
                      if [[ -f "Project.toml" ]]; then
                        echo "Activating project environment..."
                        julia --project=. "$@"
                      else
                        echo "No Project.toml found. Running Julia normally..."
                        julia "$@"
                      fi
                    }
        '';
      };
    };
}
