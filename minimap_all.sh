# Minimap alignment all vs all, script used to visualize chromosomes in Dotplotly

#!/bin/bash
#$ -cwd
#$ -V
#$ -pe smp 8

# Load module
module load minimap2

# Variables
THREADS=8
INPUT_FASTA="all_genomes_pacbio.fasta"
OUTPUT_PAF="all_vs_all.paf"

echo "Initiating alignment using Minimap2..."
date

# Ejecutar Minimap2 sin --split-prefix
minimap2 -x asm5 -t $THREADS -c $INPUT_FASTA $INPUT_FASTA > $OUTPUT_PAF

echo "Done."
date
