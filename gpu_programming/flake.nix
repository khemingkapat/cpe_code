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

      colab-start = pkgs.writeShellScriptBin "colab-start" ''
        export PATH="$HOME/.local/bin:$PATH"
        GPU="''${1:-T4}"
        SESSION="''${2:-cuda-dev}"
        echo "==> Starting Colab session '$SESSION' (GPU: $GPU)..."
        colab new -s "$SESSION" --gpu "$GPU"
      '';

      colab-stop = pkgs.writeShellScriptBin "colab-stop" ''
        export PATH="$HOME/.local/bin:$PATH"
        SESSION="''${1:-cuda-dev}"
        echo "==> Stopping Colab session '$SESSION'..."
        colab stop -s "$SESSION"
      '';

      colab-status = pkgs.writeShellScriptBin "colab-status" ''
        export PATH="$HOME/.local/bin:$PATH"
        echo "==> Active Colab sessions:"
        colab sessions
      '';

      # Embed the launcher-generator into the Nix store so colab-submit
      # always has a stable path to it regardless of where the user runs from.
      colab-launcher-gen = pkgs.writeText "colab_launcher_gen.py" ''
        import sys, textwrap

        cu_file    = sys.argv[1]
        py_out     = sys.argv[2]
        remote_src = sys.argv[3]
        remote_bin = sys.argv[4]
        arch       = sys.argv[5]
        extra_args = sys.argv[6:] if len(sys.argv) > 6 else []

        with open(cu_file, "r") as f:
            cu_source = f.read()

        cu_repr   = repr(cu_source)
        src_repr  = repr(remote_src)
        bin_repr  = repr(remote_bin)
        arch_repr = repr(arch)
        args_repr = repr(extra_args)

        launcher = textwrap.dedent(f"""\
            import subprocess, sys, pathlib

            src  = {src_repr}
            bin_ = {bin_repr}
            arch = {arch_repr}
            args = {args_repr}

            # Write source code to remote VM
            pathlib.Path(src).write_text({cu_repr})

            # Compile with nvcc
            print(f"[colab-submit] Compiling: nvcc {{src}} -o {{bin_}} -arch={{arch}}")
            r = subprocess.run(
                ["nvcc", src, "-o", bin_, f"-arch={{arch}}"],
                capture_output=True, text=True
            )
            sys.stdout.write(r.stdout)
            if r.returncode != 0:
                sys.stderr.write(r.stderr)
                sys.exit(r.returncode)

            # Execute the compiled binary with forwarded arguments
            cmd = [bin_] + args
            print("[colab-submit] Running: " + " ".join(cmd))
            sys.stdout.flush()
            sys.stderr.flush()
            r = subprocess.run(cmd, capture_output=True, text=True)
            sys.stdout.write(r.stdout)
            sys.stdout.flush()
            if r.returncode != 0:
                sys.stderr.write(r.stderr)
                sys.stderr.flush()
                sys.exit(r.returncode)
        """)

        with open(py_out, "w") as f:
            f.write(launcher)
      '';

      # colab-submit <file.cu> [-a arch] [-s session] [-t timeout] [-- <args...>]
      colab-submit = pkgs.writeShellScriptBin "colab-submit" ''
        export PATH="$HOME/.local/bin:$PATH"

        ARCH="sm_75"
        SESSION="cuda-dev"
        TIMEOUT="3600"
        FILE=""
        EXTRA_ARGS=()

        # Parse options and arguments
        while [ $# -gt 0 ]; do
          case "$1" in
            -s|--session)
              SESSION="$2"
              shift 2
              ;;
            -a|--arch)
              ARCH="$2"
              shift 2
              ;;
            -t|--timeout)
              TIMEOUT="$2"
              shift 2
              ;;
            --)
              shift
              EXTRA_ARGS+=("$@")
              break
              ;;
            *)
              if [ -z "$FILE" ]; then
                FILE="$1"
                shift
              elif [ "$ARCH" = "sm_75" ] && [[ "$1" == sm_* || "$1" == compute_* ]]; then
                ARCH="$1"
                shift
              elif [ "$SESSION" = "cuda-dev" ] && [[ "$1" =~ ^[a-zA-Z0-9_-]+$ ]] && ! [[ "$1" =~ ^[0-9]+$ ]]; then
                SESSION="$1"
                shift
              elif [ "$TIMEOUT" = "3600" ] && [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 100 ]; then
                TIMEOUT="$1"
                shift
              else
                EXTRA_ARGS+=("$1")
                shift
              fi
              ;;
          esac
        done

        if [ -z "$FILE" ]; then
          if [ -f "matmult.cu" ]; then
            FILE="matmult.cu"
          elif [ -f "matmul.cu" ]; then
            FILE="matmul.cu"
          else
            echo "Usage: colab-submit <file.cu> [-a arch] [-s session] [-t timeout] [-- <args...>]"
            echo "Example: colab-submit gpu_memory/matmult.cu"
            echo "Example: colab-submit matrix/matmul.cu -- 16"
            echo "Example: colab-submit matmult.cu -a sm_75 -s cuda-dev -t 3600"
            exit 1
          fi
        fi

        if [ ! -f "$FILE" ]; then
          echo "Error: File '$FILE' not found!"
          exit 1
        fi

        FILENAME="$(basename "$FILE")"
        BINNAME="''${FILENAME%.*}"
        REMOTE_SRC="/content/$FILENAME"
        REMOTE_BIN="/content/$BINNAME"

        echo "==> colab-submit: $FILE (arch=$ARCH) → session '$SESSION' (timeout=''${TIMEOUT}s)"
        [ ''${#EXTRA_ARGS[@]} -gt 0 ] && echo "==> Forwarded binary arguments: ''${EXTRA_ARGS[*]}"

        # ── Generate launcher using the Nix-store-embedded helper ────────────
        GEN_SCRIPT="${colab-launcher-gen}"
        LAUNCHER="$(mktemp /tmp/colab_launch_XXXXXX.py)"
        python3 "$GEN_SCRIPT" "$FILE" "$LAUNCHER" "$REMOTE_SRC" "$REMOTE_BIN" "$ARCH" "''${EXTRA_ARGS[@]}"

        echo "==> [1/2] Sending $FILENAME + launcher to Colab session '$SESSION'..."
        echo "==> [2/2] Compiling (nvcc -arch=$ARCH) and running..."
        colab exec -s "$SESSION" -f "$LAUNCHER" --timeout "$TIMEOUT"
        STATUS=$?
        rm -f "$LAUNCHER"
        exit $STATUS
      '';

      submit-colab = pkgs.writeShellScriptBin "submit-colab" ''
        exec colab-submit "$@"
      '';

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          uv # Python package & tool manager
          python3 # Needed by colab-submit launcher generator
          clang-tools # Provides clangd for C/C++/CUDA LSP
          bash-language-server # LSP for Bash and Slurm sbatch scripts
          shellcheck # Static analysis tool for shell scripts
          shfmt # Formatter for shell scripts
          slurm-ssh
          ssh-slurm
          slurm-scp
          scp-slurm
          colab-submit
          submit-colab
          colab-start
          colab-stop
          colab-status
        ];

        shellHook = ''
          export PATH="$HOME/.local/bin:$PATH"

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

          alias colab-submit='colab-submit'
          alias submit-colab='colab-submit'
          alias colab-run='colab-submit'
          alias colab-start='colab-start'
          alias colab-stop='colab-stop'
          alias colab-status='colab-status'

          echo "GPU Programming Dev Environment loaded"
          echo "Installed Tools: uv, python3, clangd (clang-tools), bash-language-server"
          echo ""
          echo "Available Shorthands:"
          echo "  slurm-ssh                     - SSH login to Slurm portal (ssh -l ${slurmUser} ${slurmHost})"
          echo "  slurm-scp <src> [dest]        - SCP transfer to Slurm portal (default dest: ~/matrix)"
          echo "  colab-submit <file.cu> [arch] - Compile (!nvcc -arch=sm_75) and run on Colab GPU"
          echo "  submit-colab <file.cu> [arch] - Alias for colab-submit"
          echo "  colab-start [gpu] [session]   - Start named Colab session (default: T4, cuda-dev)"
          echo "  colab-stop [session]          - Terminate session (default: cuda-dev)"
          echo "  colab-status                  - List active Colab sessions"
          echo ""

          # Ensure colab CLI is installed via uv tool
          if ! command -v colab >/dev/null 2>&1; then
            echo "==> 'colab' CLI not found. Installing via uv tool..."
            uv tool install google-colab-cli || echo "Failed to auto-install google-colab-cli."
          fi

          # Patch colab-cli 0.6.0 bug: jupyter_kernel_client renamed KernelClient → JupyterKernelClient
          _RUNTIME_PY=$(find "$HOME/.local/share/uv/tools/google-colab-cli" -name "runtime.py" -path "*/colab_cli/*" 2>/dev/null | head -1)
          if [ -n "$_RUNTIME_PY" ] && grep -q 'jupyter_kernel_client\.KernelClient' "$_RUNTIME_PY" 2>/dev/null; then
            sed -i 's/jupyter_kernel_client\.KernelClient/jupyter_kernel_client.JupyterKernelClient/g' "$_RUNTIME_PY"
            echo "==> Patched colab-cli runtime.py (KernelClient → JupyterKernelClient)"
          fi
          unset _RUNTIME_PY

          # Exit hook: Cleanly stop Colab session when exiting the dev environment
          _colab_cleanup() {
            if [ "''${COLAB_KEEP_ON_EXIT:-0}" = "1" ]; then
              echo "==> Dev environment exited. (COLAB_KEEP_ON_EXIT=1: preserving Colab session)"
              return 0
            fi
            if command -v colab >/dev/null 2>&1; then
              _ACTIVE=$(colab sessions 2>/dev/null | grep -v '\[?\]' | grep -c '|' || true)
              if [ "$_ACTIVE" -gt 0 ]; then
                echo ""
                echo "==> Exiting dev environment: stopping Colab session 'cuda-dev'..."
                colab stop -s cuda-dev 2>/dev/null || true
              fi
              unset _ACTIVE
            fi
          }

          # Attach to existing Colab session named 'cuda-dev', or start a new one
          if command -v colab >/dev/null 2>&1; then
            _COLAB_ACTIVE=$(colab sessions 2>/dev/null | grep -v '\[?\]' | grep -c '|' || true)
            if [ "$_COLAB_ACTIVE" -gt 0 ]; then
              echo "==> Active Colab session(s):"
              colab sessions 2>/dev/null | grep -v '\[?\]'
            else
              echo "==> No active sessions. Starting new Colab GPU session (T4, name=cuda-dev)..."
              colab new -s cuda-dev --gpu T4 || echo "Note: Run 'colab-start' to retry, or 'colab auth login' to authenticate."
            fi
            unset _COLAB_ACTIVE
          fi
          echo "  (Note: Session will auto-stop on shell exit. Set COLAB_KEEP_ON_EXIT=1 to keep running)"
          echo ""

          case "$-" in
            *i*)
              trap _colab_cleanup EXIT INT TERM HUP
              if [ -t 0 ] && [ -z "$ZSH_VERSION" ] && [ -x /home/khemi/.nix-profile/bin/zsh ]; then
                export SHELL=/home/khemi/.nix-profile/bin/zsh
                /home/khemi/.nix-profile/bin/zsh
                exit 0
              fi
              ;;
            *)
              # Non-interactive command invocation (e.g. nix develop --command ...)
              ;;
          esac
        '';
      };
    };
}
