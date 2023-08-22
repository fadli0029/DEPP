#!/bin/bash

# Read the list of submitted marker genes into an array
readarray -t SUBMITTED_GENES < trained_genes.txt

# Check if the job_outputs and depp_models directory exist; if not, create them
if [ ! -d "../job_outputs" ]; then
    mkdir job_outputs
fi

if [ ! -d "../depp_models" ]; then
    mkdir depp_models
fi

# Initialize a counter for the number of jobs submitted
JOB_COUNT=0

# Directory containing the marker genes
MARKER_DIR="../tipp2-refpkg/markers-v3"

# Loop through the marker gene directories
for MARKER_GENE_DIR in $MARKER_DIR/*.refpkg; do
    # Extract the marker gene name from the directory path
    MARKER_GENE=$(basename $MARKER_GENE_DIR .refpkg)

    # Check if the current marker gene is in the list of already trained genes
    if [[ " ${SUBMITTED_GENES[@]} " =~ " $MARKER_GENE " ]]; then
        echo "Job already submitted for $MARKER_GENE. Skipping..."
        continue
    fi

    # Dynamically generate the paths
    BACKBONE_SEQ_FILE="$MARKER_DIR/$MARKER_GENE.refpkg/${MARKER_GENE}_alignment.fasta"
    BACKBONE_TREE_FILE="$MARKER_DIR/$MARKER_GENE.refpkg/raxml_refined.taxonomy"
    MODEL_DIR="../depp_models/${MARKER_GENE}_model"

    # Check for the unwanted backbone_tree_file signature and skip if found
    if [[ $BACKBONE_TREE_FILE == *raxml_unrefined_taxonomy ]]; then
        continue
    fi

    # Create a temporary script
    TMP_SCRIPT="tmp_jobscript_$MARKER_GENE.sh"

    # Write SBATCH directives and the rest of the script to the temporary script
    cat <<EOL >$TMP_SCRIPT
#!/bin/bash
#SBATCH --job-name="$MARKER_GENE"
#SBATCH --output="../job_outputs/${MARKER_GENE}.%j.%N.out"
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

./training_script.sh --backbone_seq_file "$BACKBONE_SEQ_FILE" --backbone_tree_file "$BACKBONE_TREE_FILE" --model_dir "$MODEL_DIR"
EOL

    # Submit the temporary script to SLURM
    sbatch $TMP_SCRIPT

    # Optionally, remove the temporary script after submission
    rm $TMP_SCRIPT

    # Increment the job counter
    ((JOB_COUNT++))

    # SDSC Expanse only allows 24 running jobs for gpu-shared
    # If 24 jobs have been submitted, break out of the loop
    if [ $JOB_COUNT -ge 24 ]; then
        break
    fi

done
