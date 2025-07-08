#!/bin/bash
#$ -q all.q
#$ -cwd
#$ -N agrupar_cromosomas
#$ -V

# Ruta base donde están las carpetas de cada cepa
CEPA_DIR="/Storage/data1/isabella.gallego/MAESTRIA/data/pacbio"

# Crear carpeta de salida
mkdir -p agrupados_por_cromosoma

# Buscar todos los archivos de cromosomas por cepa
find "$CEPA_DIR" -type f -name "mror_*_group*.fasta" | while read -r fasta; do
    # Extraer nombre del grupo, por ejemplo "group1"
    grupo=$(basename "$fasta" | grep -o "group[0-9]\+")

    # Extraer nombre de la cepa desde el nombre del archivo
    cepa=$(basename "$fasta" | cut -d'_' -f2)

    # Agregar contenido con header modificado al archivo del grupo
    awk -v cepa="$cepa" '/^>/ {print ">"cepa"_"substr($0, 2)} !/^>/ {print}' "$fasta" >> agrupados_por_cromosoma/${grupo}.fasta
done

echo "Done"
