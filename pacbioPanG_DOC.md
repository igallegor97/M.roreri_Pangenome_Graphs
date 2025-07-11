# Functional Annotation and Classification of *Moniliophthora roreri* Pangenome Segments

---

## Overview

This repository contains all the scripts, data, and procedures used to perform the functional annotation and classification of segments in the *Moniliophthora roreri* pangenome constructed with **Cactus-Minigraph**.

The main goals of this pipeline are to:

- Convert the pangenome graph to formats suitable for analysis.
- Extract and classify pangenome segments as **core**, **accessory**, or **unique** based on their presence in sample genomes.
- Map gene annotations onto these segments using protein alignments.
- Generate summary statistics and visualizations.
- Provide detailed and reproducible workflows for future analyses.

---

## Directory Structure and Key Files

| File/Directory                 | Description                                                  |
|-------------------------------|--------------------------------------------------------------|
| `Mror_Pangenome_pacbio.vg`    | Original pangenome graph from Cactus-Minigraph              |
| `Mror_Pangenome_pacbio_with_W.gfa` | GFA file with added 'W' lines for paths                      |
| `paths.json`                  | JSON file representing paths extracted from the graph        |
| `gfa_samples.txt`             | List of unique sample names extracted from the GFA           |
| `proteins_fasta/`             | Original predicted protein FASTA files from genomes           |
| `proteins_fasta_cleaned/`     | Cleaned protein FASTA files (invalid characters fixed)        |
| `pangenome_segments.fa`       | Extracted segment sequences from GFA                          |
| `pangenome_segments.dmnd`     | DIAMOND protein database created from segment sequences       |
| `diamond_results/`            | Raw DIAMOND alignment results of proteins vs. segments        |
| `diamond_results_clean/`      | Filtered and cleaned DIAMOND alignment outputs                |
| `segment_classification.tsv`  | Classification of segments into core, accessory, or unique    |
| `gene_matrix.tsv`             | Matrix mapping genes to segment presence and classification   |
| `gene_lists_per_class/`       | Lists of genes exclusive to each segment class                |
| `barplot_genes_per_class.png` | Barplot visualization of gene counts per class                |
| `piechart_genes_per_class.png`| Pie chart visualization of gene distribution per class       |
| `create_gfa_with_W.py`        | Script adding 'W' lines to GFA file for path annotation        |
| `extract_all_paths_as_gfa.sh` | Shell script to extract all paths from the GFA file           |
| `generate_w_lines.py`         | Python script generating 'W' lines for GFA                    |
| `plot_class_stats.py`         | Script generating visual statistics and plots                 |

---

## Detailed Step-by-Step Workflow

### 1. Generate GFA File with Paths (`W` Lines)

- **Input:** `Mror_Pangenome_pacbio.vg`
- **Script:** `create_gfa_with_W.py`
- **Output:** `Mror_Pangenome_pacbio_with_W.gfa`

```bash
python3 create_gfa_with_W.py -i Mror_Pangenome_pacbio.vg -o Mror_Pangenome_pacbio_with_W.gfa
```
*Purpose:*
Convert the .vg graph to a GFA format while adding W lines to embed the sample paths. This facilitates segment presence analysis.

### 2. Extract Paths and Samples from GFA

- **Script:** `extract_all_paths_as_gfa.sh`
- **Output:** 
  - `gfa_samples.txt` — unique sample names extracted from P lines of the GFA.
  - `gfa_paths.txt` — all extracted path names.
```bash
 extract_all_paths_as_gfa.sh Mror_Pangenome_pacbio_with_W.gfa
```
*Purpose:*
Obtain the list of genomes (paths) embedded in the pangenome graph.

### 3. Extract Segment Sequences from GFA
```bash
vg view -Fv Mror_Pangenome_pacbio_with_W.gfa > pangenome_segments.fa
```
*Purpose:*
Export all graph nodes (segments) sequences into a FASTA file for downstream protein alignment.

### 4. Prepare and Clean Gene Annotation Files
- Original GFF3 files are located in the base directory.
- Clean invalid annotations (e.g., features with end < start) manually or with scripts.
- Extract protein sequences using genome annotation tools (e.g., gffread or custom scripts).
- Protein cleaning: Fix invalid characters in FASTA files using `fix_protein_fastas.py` (script developed during the pipeline).

### 5. Build DIAMOND Protein Database from Segments
```bash
diamond makedb --in pangenome_segments.fa -d pangenome_segments
```
*Purpose:*
Create a DIAMOND database for rapid protein alignment of gene products against pangenome segments.

### 6. Align Predicted Proteins to Pangenome Segments
```bash
for prot in proteins_fasta_cleaned/*.fa; do
  base=$(basename "$prot" .fa)
  diamond blastp -q "$prot" -d pangenome_segments -o diamond_results_clean/${base}_vs_pangenome.tsv \
    -f 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
    --evalue 1e-5 --max-target-seqs 1 --threads 4
done
```
*Purpose:*
Map gene proteins to graph segments to associate gene presence with pangenome structure.

### 7. Classify Pangenome Segments by Path Presence
- **Script:** `classify_segments_by_paths.py`
- ** Inputs:**
  - `Mror_Pangenome_pacbio_with_W.gfa`
  - `gfa_samples.txt`
  - Path-to-segment presence extracted from the graph
- **Outputs:**
  `segment_classification.tsv` (columns: segment_id, presence_count, classification)
| Class     | Description                    |
| --------- | ------------------------------ |
| Core      | Present in all sampled genomes |
| Accessory | Present in multiple, not all   |
| Unique    | Present in only one genome     |

### 8. Map Genes to Segments with Class Information
- **Script:** `map_genes_to_segments.py`
- **Inputs:**
  - Cleaned DIAMOND results
  - `segment_classification.tsv`
- **Output:** `gene_matrix.tsv` (genes annotated with segment and classification)

### 9. Generate Summary Statistics and Visualizations
- **Script:** `plot_class_stats.py`
- **Outputs:**
  - `class_summary.tsv` — count summary of segments and genes per class
  - `barplot_genes_per_class.png`
  - `piechart_genes_per_class.png`
  - `gene_lists_per_class/` — directories with lists of unique genes by class
```bash
python3 plot_class_stats.py --input gene_matrix.tsv --output_dir ./results_categories/
```
### Summary of Key Files Generated
| File                           | Description                           |
| ------------------------------ | ------------------------------------- |
| `segment_classification.tsv`   | Segment presence and classification   |
| `gene_matrix.tsv`              | Genes mapped to segments with classes |
| `class_summary.tsv`            | Numeric summary of classes            |
| `barplot_genes_per_class.png`  | Barplot visualization                 |
| `piechart_genes_per_class.png` | Pie chart visualization               |
| `gene_lists_per_class/`        | Unique gene lists per class           |

### Definitions
- ***Segment:*** A graph node representing a DNA sequence fragment in the pangenome graph.
- ***Path:*** A genome represented as a sequence of segments (nodes) in the graph.
- ***Core Segment:*** Found in all genomes (paths).
- ***Accessory Segment:*** Found in multiple but not all genomes.
- ***Unique Segment:*** Found exclusively in one genome.

### Challenges found and Solutions
***1. Invalid Characters in Protein FASTA Files***
- Problem: Some protein FASTA sequences contained invalid characters like periods . which broke DIAMOND alignment.
- Solution: Developed `fix_protein_fastas.py` to sanitize protein FASTA files by removing or replacing problematic characters.

***2. Inconsistent Sample Naming Between GFF3 and GFA Paths***
- Problem: Sample names in GFF3 gene annotation files did not always match exactly the path names in the pangenome graph.
- Solution: Created mapping files (`gff_to_gfa_mapping.tsv`) to harmonize names and ensure correct association.

***3. Large File Sizes and Computational Load***
- Problem: Pangenome graph and alignments were large (>150 GB files), causing memory and runtime issues.
- Solution:
  - Used chunking strategies with VG tools for processing smaller graph portions.
  - Utilized DIAMOND's speed and limited target sequences to top hits to reduce alignment time.
  - Parallelized alignment jobs across available CPUs.

***4. Segment Classification Complexity***
- Problem: Determining presence/absence of segments in paths required parsing complex GFA lines and paths.
- Solution: Developed custom parsing scripts (`classify_segments_by_paths.py`) that efficiently read GFA W lines and path embeddings.

### Software and Tools Used
- ***VG toolkit:*** graph processing (https://github.com/vgteam/vg)
- ***DIAMOND:*** fast protein aligner (https://github.com/bbuchfink/diamond)
- ***Python 3:*** custom scripts using pandas, matplotlib, seaborn
- ***gffread:*** annotation processing
- ***Shell scripting:*** batch commands and file parsing
