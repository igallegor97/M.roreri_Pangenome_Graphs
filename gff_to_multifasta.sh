#!/bin/bash

# 1. CREATE OUTPUT DIRECTORY
mkdir -p cds_output_all

# 2. PROCESS GFF FILES IN DIRECTORY
for gff in /home/isagallegor/M_roreri_pan/data/*.illumina.gff3
do
    # OBTAIN BASE NAME
    base=$(basename "$gff" .illumina.gff3)

    # LOCATE FASTA FILES
    fasta="/home/isagallegor/M_roreri_pan/data/${base}.illumina.fasta"

    if [[ -f "$fasta" ]]; then
        echo "Processing: $base"

        # EXTRACT CDS
        gffread "$gff" -g "$fasta" -x "/home/isagallegor/M_roreri_pan/cds_output_all/${base}_cds.fa"

    else
        echo "FASTA not found for $gff. Omit"
    fi
done

# 3. MULTI FASTA FILE CREATION
cat /home/isagallegor/M_roreri_pan/cds_output_all/*_cds.fa > /home/isagallegor/M_roreri_pan/all_cds_for_psauron.fasta

echo "DONE. File name: all_cds_for_psauron.fasta"
