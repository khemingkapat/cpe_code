#!/bin/bash
#SBATCH --job-name=matmull
#SBATCH --output=slurm-%j.log
#SBATCH --partition=gpu4090
#SBATCH --gres=gpu:rtx4090:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:10:00

source /etc/profile
set -euo pipefail

echo "=== Host ==="
hostname
date

echo "=== Load CUDA Module ==="
module purge
module load cuda/12.2
module list

echo "=== Compiler Info ==="
gcc-12 --version
g++-12 --version
nvcc --version

echo "=== GPU Info ==="
nvidia-smi

echo "=== Compile ==="
nvcc -ccbin /usr/bin/g++-12 matmul.cu -o matmul

echo "=== Run ==="
./matmul 4

