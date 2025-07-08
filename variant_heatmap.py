import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

# Load genotypes file
gt_file = "variant_analysis/genotypes/genotypes.tsv"

# Read file
df = pd.read_csv(gt_file, sep="\t")

# Transform genotypes to numeric data
def gt_to_num(gt):
    if gt == "0/0":
        return 0
    elif gt in ("0/1", "1/0"):
        return 1
    elif gt == "1/1":
        return 2
    else:
        return np.nan

# Apply function to each cell (except CHROM and POS)

for col in df.columns[2:]:
    df[col] = df[col].apply(gt_to_num)

# Set index as position in heatmap

df['variant_id'] = df['#CHROM'] + ":" + df['POS'].astype(str)
df.set_index('variant_id', inplace=True)

# Only sample columns
gt_matrix = df.iloc[:, 2:]

# Select random variants to plot (to reduce heatmap size)
gt_sample = gt_matrix.sample(n=500, random_state=42)

# Plot heatmap
plt.figure(figsize=(12,8))
sns.heatmap(gt_sample.T, cmap="viridis", cbar_kws={'label': 'Genotype'}, yticklabels=True)
plt.title("Genotype heatmap - 500 random variants")
plt.xlabel("Variants")
plt.ylabel("Sample")
plt.tight_layout()
plt.savefig("variant_analysis/genotypes_heatmap.png")
plt.show()
