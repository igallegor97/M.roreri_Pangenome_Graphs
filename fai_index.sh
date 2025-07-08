#!/bin/bash
#$ -q all.q
#$ -cwd

module load Samtools   # carga samtools en el cluster

cd /Storage/data1/isabella.gallego/MAESTRIA/data/pacbio/agrupados_por_cromosoma

for f in group*.fasta; do
  if [ ! -f "${f}.fai" ]; then
    echo "Indexando $f..."
    samtools faidx "$f"
  else
    echo "Índice ya existe para $f, saltando."
  fi
done
