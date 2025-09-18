#!/usr/bin/env bash
set -euo pipefail

# Complete Starfish runbook for M. roreri using starfish_ready

THREADS=4
DATADIR="/home/isagallegor/M_roreri_pan/starfish_ready"
PROJECT="starfish_mror"
PREFIX="mror24"

mkdir -p "$PROJECT"
cd "$PROJECT"

# Locate STARFISHDIR
STARFISHDIR=$(dirname -- "$(command -v starfish)")/../
echo "STARFISHDIR = $STARFISHDIR"

# 0) Gather file lists and create control files

find "$DATADIR" -maxdepth 1 -type f -iname "*.genes.fasta" | sort > fasta_list.txt
find "$DATADIR" -maxdepth 1 -type f -iname "*.gff3" | sort > gff_list.txt

echo "Found FASTA files: $(wc -l < fasta_list.txt)"
echo "Found GFF files:   $(wc -l < gff_list.txt)"

# Create ome2assembly.txt and ome2gff.txt
rm -f ome2assembly.txt ome2gff.txt
while read -r f; do
    id=$(basename "$f")
    id="${id%%.genes*}"   # corta desde .genes en adelante
    echo -e "${id}\t$(realpath "$f")"
done < fasta_list.txt > ome2assembly.txt

while read -r g; do
    id=$(basename "$g"); id="${id%.*}"
    echo -e "${id}\t$(realpath "$g")"
done < gff_list.txt > ome2gff.txt

# Check assembly/GFF ID consistency
printf "IDs only in assemblies (non-matching):\n"
comm -23 <(cut -f1 ome2assembly.txt | sort) <(cut -f1 ome2gff.txt | sort) || true
printf "IDs only in GFFs (non-matching):\n"
comm -13 <(cut -f1 ome2assembly.txt | sort) <(cut -f1 ome2gff.txt | sort) || true

# 1) Concatenate GFFs and build BLAST DB

echo "Concatenating GFFs..."
> ${PREFIX}.all.gff3
while read -r id gff_file; do
    cat "$gff_file" >> ${PREFIX}.all.gff3
done < ome2gff.txt
echo "GFF concatenation complete."

echo "Concatenating FASTA assemblies..."
mkdir -p blastdb
> blastdb/${PREFIX}.assemblies.fna
while read -r id fasta_file; do
    cat "$fasta_file" >> blastdb/${PREFIX}.assemblies.fna
done < fasta_list.txt
echo "FASTA concatenation complete."

# Basic sanity: show top 5 headers
echo "First 5 fasta headers from concatenated assemblies:"
grep '^>' blastdb/${PREFIX}.assemblies.fna | head -n 5 || true

# Build BLAST database
echo "Building BLAST database..."
makeblastdb -in blastdb/${PREFIX}.assemblies.fna \
            -dbtype nucl \
            -parse_seqids \
            -out blastdb/${PREFIX}.assemblies
echo "BLAST database built successfully."

# Optional: GC% windows
if [ -x "${STARFISHDIR}/aux/seq-gc.sh" ]; then
    "${STARFISHDIR}/aux/seq-gc.sh" -Nbw 1000 blastdb/${PREFIX}.assemblies.fna > ${PREFIX}.assemblies.gcContent_w1000.bed
fi

# Validate contig names
grep '^>' blastdb/${PREFIX}.assemblies.fna | sed 's/^>//' | awk '{print $1}' | sort -u > fasta_contigs.txt
awk '/^[^#]/{print $1}' ${PREFIX}.all.gff3 | sort -u > gff_contigs.txt
echo "Contigs in FASTA but not in GFF (first 20):"
comm -23 fasta_contigs.txt gff_contigs.txt | head -n 20 || true
echo "Contigs in GFF but not in FASTA (first 20):"
comm -13 fasta_contigs.txt gff_contigs.txt | head -n 20 || true


# 2) Prepare annotation/OG files

mkdir -p ann
if ls "$DATADIR"/*emapper*.annotations 1> /dev/null 2>&1; then
  echo "Parsing emapper annotation outputs..."
  cut -f1,12 "$DATADIR"/*emapper*.annotations \
    | grep -v '#' \
    | grep -v -P '\t-' \
    | perl -pe 's/\t/\tEMAP\t/' \
    | grep -vP '\tNA' \
    > ann/${PREFIX}.gene2emap.txt || true

  cut -f1,10 "$DATADIR"/*emapper*.annotations \
    | grep -v '#' \
    | perl -pe 's/^([^\s]+?)\t([^\|]+).+$/\1\t\2/' \
    > ann/${PREFIX}.gene2og.txt || true
else
  echo "No emapper outputs found in starfish_ready — continuing without gene2emap/gene2og."
fi

if [ -s ann/${PREFIX}.gene2og.txt ]; then
  "${STARFISHDIR}/aux/geneOG2mclFormat.pl" -i ann/${PREFIX}.gene2og.txt -o ann/ || true
fi

# 3) GENE FINDER (TYR)

mkdir -p geneFinder
starfish annotate -T $THREADS -x $PREFIX -a ome2assembly.txt -g ome2gff.txt \
  -p "${STARFISHDIR}/db/YRsuperfams.p1-512.hmm" \
  -P "${STARFISHDIR}/db/YRsuperfamRefs.faa" \
  -i tyr -o geneFinder/ || true

starfish consolidate -o ./ -g ${PREFIX}.all.gff3 -G geneFinder/${PREFIX}_tyr.filt_intersect.gff || true
realpath ${PREFIX}_tyr.filt_intersect.consolidated.gff | perl -pe 's/^/mror\t/' > ome2consolidatedGFF.txt

# Handle missing TYRs
touch geneFinder/${PREFIX}_tyr.filt_intersect.gff
touch geneFinder/${PREFIX}.tyr.filt_intersect.ids
touch geneFinder/${PREFIX}.bed
echo "No TYRs detected — continuing with ELEMENT FINDER."


# 4) ELEMENT FINDER

mkdir -p elementFinder
starfish insert -T $THREADS -a ome2assembly.txt -d blastdb/${PREFIX}.assemblies \
  -b geneFinder/${PREFIX}.bed -i g -x $PREFIX -o elementFinder/ || true

starfish summarize -a ome2assembly.txt -b elementFinder/${PREFIX}.insert.bed -x $PREFIX -o elementFinder/ \
  -S elementFinder/${PREFIX}.insert.stats -g ome2consolidatedGFF.txt \
  -A ann/${PREFIX}.gene2emap.txt || true

# Optional: color bed
awk '{
  if ($4 ~ /DR/) print $0 "\t255,255,0";
  else if ($4 ~ /TIR/) print $0 "\t255,165,0";
  else if ($5 != ".") print $0 "\t128,0,128";
  else print $0 "\t169,169,169";
}' elementFinder/${PREFIX}.elements.bed > elementFinder/${PREFIX}.elements.color.bed || true

# Classify families
mmseqs easy-cluster geneFinder/${PREFIX}.bed elementFinder/${PREFIX}_gene elementFinder/ \
  --threads $THREADS --min-seq-id 0.5 -c 0.25 --alignment-mode 3 --cov-mode 0 --cluster-reassign || true
"${STARFISHDIR}/aux/mmseqs2mclFormat.pl" -i elementFinder/${PREFIX}_gene_cluster.tsv -g navis -o elementFinder/ || true

starfish sim -m element -t nucl -b elementFinder/${PREFIX}.elements.bed -x $PREFIX -o elementFinder/ -a ome2assembly.txt || true
starfish group -m mcl -s elementFinder/${PREFIX}.element.nucl.sim -i hap -o elementFinder/ -t 0.05 || true

"${STARFISHDIR}/aux/mergeGroupfiles.pl" \
  -t elementFinder/${PREFIX}.element_cluster.mcl \
  -q elementFinder/${PREFIX}.element.nucl.I1.5.mcl \
  > elementFinder/${PREFIX}.element.navis-hap.mcl || true

awk '{ for (i = 2; i <= NF; i++) print $i"\t"$1 }' \
  elementFinder/${PREFIX}.element.navis-hap.mcl > elementFinder/${PREFIX}.element.navis-hap.txt || true


# 5) REGION FINDER

mkdir -p regionFinder

starfish dereplicate -a ome2assembly.txt -b elementFinder/${PREFIX}.elements.bed -i element -x $PREFIX -o regionFinder/ || true
starfish dereplicate -a ome2assembly.txt -b elementFinder/${PREFIX}.elements.bed -i captain -x $PREFIX -o regionFinder/ || true
starfish dereplicate -a ome2assembly.txt -b elementFinder/${PREFIX}.elements.bed -i cargo -x $PREFIX -o regionFinder/ || true
starfish dereplicate -a ome2assembly.txt -b geneFinder/${PREFIX}.bed -i neighborhood -x $PREFIX -o regionFinder/ || true

starfish map -v assembly -A nucmer -b regionFinder/${PREFIX}.reps --minLength 10000 --pid 95 \
  -x $PREFIX -o regionFinder/ -a ome2assembly.txt --plus --minus || true

starfish ome2assembly -i regionFinder/${PREFIX}.assembly.nucl.sim --plus --minus --percentile 99 \
  -g ome2consolidatedGFF.txt -n muts -S elementFinder/${PREFIX}.elements.stats -O $PREFIX -a 0.1 -o regionFinder/ || true

starfish ome2annotation -g ome2consolidatedGFF.txt -I elementFinder/${PREFIX}.elements.bed \
  -a elementFinder/${PREFIX}.elements.ann.feat -C elementFinder/${PREFIX}.element.navis-hap.txt \
  -M ann/${PREFIX}.gene2emap.txt -o regionFinder/ -x $PREFIX -A nucmer || true

echo "Pipeline completed. Results are in geneFinder/, elementFinder/, regionFinder/"
