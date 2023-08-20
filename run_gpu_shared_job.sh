#!/bin/bash
#SBATCH --job-name="MarkerGene_"
#SBATCH --output="depp.%j.%N.out"
#SBATCH --partition=gpu-shared
#SBATCH --nodes=1
#SBATCH -t 48:00:00
#SBATCH --mem=90G
#SBATCH --ntasks-per-node=4
#SBATCH --gpus=1
#SBATCH --account=uot138
#SBATCH --constraint="lustre"

module purge
module restore
module load gpu/0.15.4
module load anaconda3
module load cuda/11.0.2
module list

./training_script.sh
