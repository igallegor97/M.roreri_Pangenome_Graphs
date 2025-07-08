#!/bin/bash

# Activate Env
module load miniconda3
conda activate vcf_env

# Input and output files
VCF="Mror_Pangenome_pacbio.vcf.gz"
OUTDIR="variant_analysis"
mkdir -p "$OUTDIR/plots" "$OUTDIR/genotipes"

echo "[INFO] Analyzing file $VCF"

# General stats and plots
echo "[INFO] Generating stats using bcftools..."
bcftools stats "$VCF" > "$OUTDIR/stats_pacbio.txt"

echo "[INFO] Creating plots using plot-vcfstats..."
plot-vcfstats -p "$OUTDIR/plots" "$OUTDIR/stats_pacbio.txt"

# Variant counts by type

echo "[INFO] Counting SVs..."
echo ">>> Deletions (DEL):" > "$OUTDIR/variant_count.txt"
bcftools view -i 'SVTYPE="DEL"' "$VCF" | wc -l >> "$OUTDIR/variant_count.txt"

echo ">>> Insertions (INS):" >> "$OUTDIR/variant_count.txt"
bcftools view -i 'SVTYPE="INS"' "$VCF" | wc -l >> "$OUTDIR/variant_count.txt"

echo ">>> Inversions (INV):" >> "$OUTDIR/variant_count.txt"
bcftools view -i 'SVTYPE="INV"' "$VCF" | wc -l >> "$OUTDIR/variant_count.txt"

echo "" >> "$OUTDIR/variant_count.txt"
echo ">>> SNPs:" >> "$OUTDIR/variant_count.txt"
bcftools view -v snps "$VCF" | wc -l >> "$OUTDIR/variant_count.txt"

echo ">>> Indels:" >> "$OUTDIR/variant_count.txt"
bcftools view -v indels "$VCF" | wc -l >> "$OUTDIR/variant_count.txt"

echo "[INFO] Variant counts saven in $OUTDIR/variant_count.txt"

# Genotypes by position
echo "[INFO] Extracting genotype by position matrix..."
bcftools query -f '%CHROM\t%POS[\t%GT]\n' "$VCF" > "$OUTDIR/genotypes/genotypes.tsv"

echo "[INFO] Done. Results in: $OUTDIR"
