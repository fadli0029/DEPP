#!/bin/bash

###############################################################################
# ============================= CLONING THE REPO ============================ #
###############################################################################
repo_name="DEPP"

# Check if the directory exists
if [ -d "$repo_name" ]; then
    echo "Repo exists, deleting it..."
    rm -rf DEPP
    echo "Cloning the repo..."
    git clone https://github.com/fadli0029/DEPP.git
    exit 1
else
    echo "Repo DO NOT exists, cloning it..."
    git clone https://github.com/fadli0029/DEPP.git
fi

# Going to the repo directory
echo "Going to the repo directory..."
cd DEPP

# Creating and activating conda environment
echo "Creating and activating conda environment..."
conda env create -f depp_env.yml
rm depp_env.yml
conda activate depp_env

###############################################################################
# ==================== DONWLOADING THE REFERENCE PACKAGE ==================== #
###############################################################################
echo "Downloading the reference package (tipp2-refpkg)..."

# URL of the tar.gz file
url="https://obj.umiacs.umd.edu/tipp/tipp2-refpkg.tar.gz"

# Name of the directory that will be created when the tar.gz file is extracted
dir_name="tipp2-refpkg"

# Check if the directory exists
if [ -d "$dir_name" ]; then
    echo "Reference package directory already exists $dir_name already exists. Aborted downloading attempt..."
    exit 1
else
    # Download the file
    wget "$url"

    # Extract the file
    tar -xzf tipp2-refpkg.tar.gz

    # Remove the downloaded tar.gz file
    rm tipp2-refpkg.tar.gz
fi

###############################################################################
# ============================ TRAINING THE MODEL =========================== #
###############################################################################
echo "##########################################################"
echo "Training the model from scratch (with GPU, 1001 epochs)..."
echo
echo "backbone_seq_file:"
echo "tipp2-refpkg/markers-v3/ArgS_COG0018.refpkg/ArgS_COG0018_alignment.fasta"
echo
echo "backbone_tree_file: ..."
echo "tipp2-refpkg/markers-v3/args_cog0018.refpkg/raxml_refined.taxonomy"
echo
echo "Model directory: test/basic/test_model"
echo "##########################################################"

# Makes sure to remove directory if it exists
tipp2-refpkg/markers-v3/ArgS_COG0018.refpkg
rm -rf test/basic/test_model
python train_depp.py backbone_seq_file=tipp2-refpkg/markers-v3/ArgS_COG0018.refpkg/ArgS_COG0018_alignment.fasta backbone_tree_file=tipp2-refpkg/markers-v3/args_cog0018.refpkg/raxml_refined.taxonomy model_dir=test/basic/test_model epoch=1001
