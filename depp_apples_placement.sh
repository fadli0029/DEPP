#!/bin/bash

backbone_seq_file=""
query_seq_file=""
model_path=""
tree_file=""
output_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --backbone_seq_file)
      shift
      backbone_seq_file="$1"
      ;;
    --query_seq_file)
      shift
      query_seq_file="$1"
      ;;
    --model_path)
      shift
      model_path="$1"
      ;;
    --tree_file)
      shift
      tree_file="$1"
      ;;
    --output_path)
      shift
      output_path="$1"
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done

echo
echo
echo "====================> Calculating Distance Matrices With DEPP <===================="
depp_distance.py backbone_seq_file=${backbone_seq_file} query_seq_file=${query_seq_file} model_path=${model_path}
if [ -f "depp.csv" ]; then
    echo "Done calculating distance matrices!"
    echo "====================> Running APPLES Placement <===================="
    apples.py -t ${tree_file} -d depp.csv -o depp_apples_placement
    run_apples.py -d depp.csv -t ${tree_file} -o ${output_path}/placement.jplace > /dev/null 2>&1
else
    echo "Problem calculating distance matrices! depp.csv not generated."
fi

gappa examine graft --jplace-path ${output_path}/ --out-dir ${output_path}/ --allow-file-overwriting > /dev/null 2>&1
echo "Finish queries placement!"
