#!/usr/bin/env python3
"""
colab_launcher_gen.py
Generates a self-contained Python launcher script for colab exec.
Args: <cu_file> <launcher_out.py> <remote_src> <remote_bin> <arch>
"""
import sys, textwrap

cu_file    = sys.argv[1]
py_out     = sys.argv[2]
remote_src = sys.argv[3]
remote_bin = sys.argv[4]
arch       = sys.argv[5]
extra_args = sys.argv[6:] if len(sys.argv) > 6 else []

with open(cu_file, 'r') as f:
    cu_source = f.read()

# Use repr() so the source is safely embedded as a Python string literal
cu_repr    = repr(cu_source)
src_repr   = repr(remote_src)
bin_repr   = repr(remote_bin)
arch_repr  = repr(arch)
args_repr  = repr(extra_args)

launcher = textwrap.dedent(f"""\
    import subprocess, sys, pathlib

    src  = {src_repr}
    bin_ = {bin_repr}
    arch = {arch_repr}
    args = {args_repr}

    # Write the .cu source onto the Colab VM filesystem
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

with open(py_out, 'w') as f:
    f.write(launcher)

print(f"[colab-submit] Launcher written to {py_out}", file=sys.stderr)
