#!/bin/bash

set -e
echo "[INFO] Starting variant analysis pipeline"

# Define paths
VCF="data/Mror_Pangenome_pacbio_annotated.vcf"
GENOTYPES="data/genotypes.tsv"
OUTDIR="variant_analysis"
mkdir -p "$OUTDIR/stats" "$OUTDIR/plots" "$OUTDIR/reports"

echo "[INFO] Running bcftools stats..."
bcftools stats "$VCF" > "$OUTDIR/stats/stats_pacbio.txt"
plot-vcfstats -p "$OUTDIR/plots" "$OUTDIR/stats/stats_pacbio.txt"

echo "[INFO] Counting variant types..."
python3 scripts/count_variant_types.py --vcf "$VCF" --out "$OUTDIR/stats/variant_counts.txt"

# echo "[INFO] Generating genotype heatmap..."
python3 scripts/genotype_heatmap.py --genotypes "$GENOTYPES" --outdir "$OUTDIR/plots"

# PCA and clustering temporarily disabled
# echo "[INFO] Running PCA and clustering..."
# python3 scripts/pca_clustering.py --genotypes "$GENOTYPES" --outdir "$OUTDIR/plots" --reportdir "$OUTDIR/reports"

echo "[INFO] Pipeline finished. Check $OUTDIR for results."
