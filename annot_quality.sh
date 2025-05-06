#!/bin/bash

# CONFIG 
GENOME="Mror_C26.illumina.fasta"
GFF="Mror_C26.illumina.gff3"
PREFIX="C26"
WORKDIR="/home/isagallegor/M_roreri_pan"
OMAMER_DB="LUCA.h5"

# ENTER WORKDIR
cd "$WORKDIR" || exit

# 1. EXTRACT CDS WITH GFFREAD
echo "Extracting CDS with gffread"
gffread "$GFF" -g "$GENOME" -x output_CDS_"$PREFIX".fasta

# 2. TRANSLATE CDS TO PROTEINS WITH TRANSEQ
echo "Translating CDS to proteins with transeq"
transeq -sequence output_CDS_"$PREFIX".fasta -outseq output_proteins_"$PREFIX".fasta

# 3. Filter proteins (one per gene) with Biopython
echo "Filtering"
python3 <<EOF
from Bio import SeqIO
from collections import defaultdict

input_file = "output_proteins_${PREFIX}.fasta"
output_file = "final_proteome_${PREFIX}.fasta"

gene_dict = defaultdict(list)
for record in SeqIO.parse(input_file, "fasta"):
    gene_id = record.id.split(".")[0]
    gene_dict[gene_id].append(record)

selected_records = []
for records in gene_dict.values():
    longest = max(records, key=lambda x: len(x.seq))
    selected_records.append(longest)

SeqIO.write(selected_records, output_file, "fasta")
print("Final proteome written in", output_file)
EOF

echo "Done"

# 4. RUN OMAmer ANNOTATION
echo "Running OMAmer with ${OMAMER_DB}"
omamer search -q final_proteome_"$PREFIX".fasta -d "$OMAMER_DB" -o omamer_assignments_"$PREFIX".tsv 

# 5. RUN OMArk QUALITY ASSESSMENT 
echo "Running OMArk with ${OMAMER_DB}"
omark -f omamer_assignments_"$PREFIX".tsv -d "$OMAMER_DB" -o output_omark_"$PREFIX" -of "${WORKDIR}/final_proteome_${PREFIX}.fasta"

echo "Pipeline completed"
