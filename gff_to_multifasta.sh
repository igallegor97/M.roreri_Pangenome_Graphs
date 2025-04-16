#!/bin/bash

#$ -q all.q
#$ -V
#$ -cwd

source /Storage/progs/miniconda3/condabin/conda
conda activate psauron

BASE_DIR=$(pwd)

# DEFINE DIRECTORIES
DATA_DIR="$BASE_DIR/data/calidad_anots/"
OUTPUT_DIR="$BASE_DIR/cds_output_all"
OUTPUT_FASTA="$BASE_DIR/all_cds_for_psauron.fasta"

# 1. CREATE OUTPUT DIRECTORY
mkdir -p "$OUTPUT_DIR"

# 2. PROCESS GFF FILES IN DIRECTORY
for gff in "$DATA_DIR"/*.illumina.gff3
do
    base=$(basename "$gff" .illumina.gff3)
    fasta="$DATA_DIR/${base}.illumina.fasta"

    if [[ -f "$fasta" ]]; then
        echo "Procesando: $base"
        gffread "$gff" -g "$fasta" -x "$OUTPUT_DIR/${base}_cds.fa"
    else
        echo "FASTA not found for $gff. Omited."
    fi
done

# 3. MULTI FASTA FILE CREATION
cat "$OUTPUT_DIR"/*_cds.fa > "$OUTPUT_FASTA"

echo "DONE. File name: $OUTPUT_FASTA"
