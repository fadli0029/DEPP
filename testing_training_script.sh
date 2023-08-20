#!/bin/bash

# Parse the arguments, easily allow to train all 40 marker genes from job script.
BACKBONE_SEQ_FILE=""
BACKBONE_TREE_FILE=""
MODEL_DIR=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --backbone_seq_file) BACKBONE_SEQ_FILE="$2"; shift ;;
        --backbone_tree_file) BACKBONE_TREE_FILE="$2"; shift ;;
        --model_dir) MODEL_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

###############################################################################
# ============================= CLONING THE REPO ============================ #
###############################################################################
echo
echo
echo "===============> Cloning the repo..."
repo_name="DEPP"

# Check if the directory exists
if [ -d "$repo_name" ]; then
    echo "Repo exists, cd'ing to DEPP and pulling from main branch..."
    cd DEPP
    git pull
else
    echo "Repo DO NOT exists, cloning it and cd'ing into DEPP..."
    git clone https://github.com/fadli0029/DEPP.git
    echo "===============> Going to the repo directory..."
    cd DEPP
    pwd
fi

# Creating and activating conda environment
echo
echo
echo "===============> Attempting to install conda environment depp_env..."
env_name="depp_env"
# Check if the environment exists
if conda env list | grep -q "$env_name"; then
    echo "Conda environment $env_name exists. Activating..."
    source ~/.bashrc
    conda activate depp_env
    echo "Checking which conda env. currently in used:"
    conda info --env
else
    echo "Conda environment $env_name does not exist."
    echo "Creating and activating conda environment..."
    conda env create -f depp_env.yml
    source ~/.bashrc
    conda activate depp_env
    echo "Checking which conda env. currently in used:"
    conda info --env
fi

###############################################################################
# ====================== CHECKING IF CUDA IS AVAILABLE ====================== #
###############################################################################
echo
echo
echo "===============> Checking if CUDA is available..."
touch check_cuda_available.py
echo "import torch" >> check_cuda_available.py
echo "if torch.cuda.is_available():" >> check_cuda_available.py
echo "  print('#################')" >> check_cuda_available.py
echo "  print('CUDA is available')" >> check_cuda_available.py
echo "  print('#################')" >> check_cuda_available.py
echo "else:" >> check_cuda_available.py
echo "  print('#####################')" >> check_cuda_available.py
echo "  print('CUDA is NOT available')" >> check_cuda_available.py
echo "  print('#####################')" >> check_cuda_available.py
python check_cuda_available.py
rm check_cuda_available.py

###############################################################################
# ======================= CHECKING NODE CONFIGURATION ======================= #
###############################################################################
echo
echo
echo "===============> Checking node configuration..."
nvidia-smi

###############################################################################
# =================== CHECKING PYTORCH LIGHTNING VERSION ==================== #
###############################################################################
echo
echo
echo "===============> Fixing pytorch-lightning installation (need v1.5.0)"
if pip show pytorch_lightning| grep -q "1.5.0"; then
    echo "pytorch-lightning version is compatible!"
else
    echo "Installing pytorch-lightning v1.5.0..."
    python -m pip install --user pytorch-lightning==1.5.0
fi
pip show pytorch_lightning

###############################################################################
# ==================== DONWLOADING THE REFERENCE PACKAGE ==================== #
###############################################################################
echo
echo
echo "===============> Downloading the reference package (tipp2-refpkg)..."

# URL of the tar.gz file
url="https://obj.umiacs.umd.edu/tipp/tipp2-refpkg.tar.gz"

# Name of the directory that will be created when the tar.gz file is extracted
dir_name="TESTING-tipp2-refpkg"

# Check if the directory exists
if [ -d "$dir_name" ]; then
    echo "Reference package directory $dir_name already exists. Aborted downloading attempt..."
else
    echo "No TESTING-tipp2-refpkg found! Exiting!"
    exit 1
fi

###############################################################################
# ============================ TRAINING THE MODEL =========================== #
###############################################################################
echo
echo
echo "########################################################################"
echo "########################################################################"
echo "Training the model from scratch (with GPU, 1001 epochs)..."
echo
echo "backbone_seq_file:"
echo "$BACKBONE_SEQ_FILE"
echo
echo "backbone_tree_file:"
echo "$BACKBONE_TREE_FILE"
echo
echo "Model directory:"
echo "$MODEL_DIR"
echo "########################################################################"
echo "########################################################################"

echo
echo
# Makes sure to remove directory if it exists
rm -rf test/basic/test_model
python train_depp.py backbone_seq_file="$BACKBONE_SEQ_FILE" backbone_tree_file="$BACKBONE_TREE_FILE" model_dir="$MODEL_DIR" gpus='[0]' epoch=1001
# python train_depp.py backbone_seq_file=tipp2-refpkg/markers-v3/ArgS_COG0018.refpkg/ArgS_COG0018_alignment.fasta backbone_tree_file=tipp2-refpkg/markers-v3/ArgS_COG0018.refpkg/raxml_refined.taxonomy model_dir=test/basic/test_model gpus='[0]' epoch=1001
