# Análisis de calidad de anotaciones

# Convertir los GFF3 a FASTA
# Extraer las secuencias de CDS
gffread /Users/isaga/OneDrive/Documentos/Maestria/M_roreri_pan/Mror_C26.illumina.gff3 -g /Users/isaga/OneDrive/Documentos/Maestria/M_roreri_pan/Mror_C26.illumina.fasta -x output_CDS_C26.fasta

# Traducir las secuencias CDS a proteinas
transeq -sequence output_CDS_C26.fasta -outseq output_proteins.fasta

# Dejar una sola proteína por gen
from Bio import SeqIO
from collections import defaultdict

# Cargar proteínas y agrupar por gen
gene_dict = defaultdict(list)

for record in SeqIO.parse("output_proteins.fasta", "fasta"):
    gene_id = record.id.split(".")[0]  # Elimina el identificador de isoformas (si está presente)
    gene_dict[gene_id].append(record)

# Elegir la proteína más larga para cada gen
selected_records = []
for gene_id, records in gene_dict.items():
    longest_record = max(records, key=lambda x: len(x.seq))
    selected_records.append(longest_record)

# Guardar el nuevo FASTA con solo una proteína por gen
SeqIO.write(selected_records, "final_proteome.fasta", "fasta")

# Análisis de calidad
# OMAmer
omamer search -d LUCA.h5 -q /home/isabellagallego/Documentos/output_CDS_C26.fasta -o OMAmer_out --silent

# OMARk
omark (-f FILE | -c) -d LUCA.h5 -o /home/isabellagallego/Documentos/OMARk_Results
