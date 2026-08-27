{
  description = "GPU Programming Environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      slurmUser = "66070503408@cpe.kmutt.ac.th";
      slurmHost = "portal.slurm.cpe.kmutt.ac.th";

      slurm-ssh = pkgs.writeShellScriptBin "slurm-ssh" ''
        exec ssh -l ${slurmUser} ${slurmHost} "$@"
      '';

      ssh-slurm = pkgs.writeShellScriptBin "ssh-slurm" ''
        exec ssh -l ${slurmUser} ${slurmHost} "$@"
      '';

      slurm-scp = pkgs.writeShellScriptBin "slurm-scp" ''
        if [ $# -lt 1 ]; then
          echo "Usage: slurm-scp <source> [destination]"
          echo "Example: slurm-scp matrix/matmul.cu ~/matrix"
          exit 1
        fi
        SRC="$1"
        DEST="''${2:-~/matrix}"
        exec scp -r "$SRC" "${slurmUser}@${slurmHost}:$DEST"
      '';

      scp-slurm = pkgs.writeShellScriptBin "scp-slurm" ''
        if [ $# -lt 1 ]; then
          echo "Usage: scp-slurm <source> [destination]"
          echo "Example: scp-slurm matrix/matmul.cu ~/matrix"
          exit 1
        fi
        SRC="$1"
        DEST="''${2:-~/matrix}"
        exec scp -r "$SRC" "${slurmUser}@${slurmHost}:$DEST"
      '';

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          clang-tools # Provides clangd for C/C++/CUDA LSP
          bash-language-server # LSP for Bash and Slurm sbatch scripts
          shellcheck # Static analysis tool for shell scripts
          shfmt # Formatter for shell scripts
          slurm-ssh
          ssh-slurm
          slurm-scp
          scp-slurm
        ];

        shellHook = ''
          # Define shell aliases and functions for interactive shells
          alias slurm-ssh='ssh -l ${slurmUser} ${slurmHost}'
          alias ssh-slurm='ssh -l ${slurmUser} ${slurmHost}'

          slurm-scp() {
            if [ $# -lt 1 ]; then
              echo "Usage: slurm-scp <source> [destination]"
              echo "Example: slurm-scp matrix/matmul.cu ~/matrix"
              return 1
            fi
            local SRC="$1"
            local DEST="''${2:-~/matrix}"
            scp -r "$SRC" "${slurmUser}@${slurmHost}:$DEST"
          }
          alias scp-slurm=slurm-scp

          echo "GPU Programming Dev Environment loaded"
          echo "Installed LSPs: clangd (clang-tools), bash-language-server"
          echo ""
          echo "Available Shorthands:"
          echo "  slurm-ssh              - SSH login to Slurm portal (ssh -l ${slurmUser} ${slurmHost})"
          echo "  slurm-scp <src> [dest] - SCP transfer to Slurm portal (default dest: ~/matrix)"
          echo ""

          if [ -z "$ZSH_VERSION" ] && [ -x /home/khemi/.nix-profile/bin/zsh ]; then
            export SHELL=/home/khemi/.nix-profile/bin/zsh
            exec /home/khemi/.nix-profile/bin/zsh
          fi
        '';
      };
    };
}
