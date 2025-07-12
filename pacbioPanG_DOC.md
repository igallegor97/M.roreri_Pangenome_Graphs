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

| File/Directory                            | Description                                                               |
| ----------------------------------------- | ------------------------------------------------------------------------- |
| `Mror_Pangenome_pacbio.vg`                | Original pangenome graph from Cactus-Minigraph                            |
| `Mror_Pangenome_pacbio_with_W.gfa`        | GFA file with added 'W' lines for paths                                   |
| `paths.json`                              | JSON file representing paths extracted from the graph                     |
| `gfa_samples.txt`                         | List of unique sample names extracted from the GFA                        |
| `proteins_fasta/`                         | Original predicted protein FASTA files from genomes                       |
| `proteins_fasta_cleaned/`                 | Cleaned protein FASTA files (invalid characters fixed)                    |
| `pangenome_segments.fa`                   | Extracted segment sequences from GFA                                      |
| `pangenome_segments.dmnd`                 | DIAMOND protein database created from segment sequences                   |
| `diamond_results/`                        | Raw DIAMOND alignment results of proteins vs. segments                    |
| `diamond_results_clean/`                  | Filtered and cleaned DIAMOND alignment outputs                            |
| `segment_classification.tsv`              | Classification of segments into core, accessory, or unique                |
| `gene_matrix.tsv`                         | Matrix mapping genes to segment presence and classification               |
| `gene_lists_per_class/`                   | Lists of genes exclusive to each segment class                            |
| `barplot_genes_per_class.png`             | Barplot visualization of gene counts per class                            |
| `piechart_genes_per_class.png`            | Pie chart visualization of gene distribution per class                    |
| `create_gfa_with_W.py`                    | Script adding 'W' lines to GFA file for path annotation                   |
| `extract_all_paths_as_gfa.sh`             | Shell script to extract all paths from the GFA file                       |
| `generate_w_lines.py`                     | Python script generating 'W' lines for GFA                                |
| `plot_class_stats.py`                     | Script generating visual statistics and plots                             |
| `hmmscan_results_cleaned/`                | Directory with HMMER hmmscan output domain table files                    |
| `all_pfams.tsv`                           | Consolidated PFAM domain hits parsed from hmmscan outputs                 |
| `orthofinder_out/`                        | OrthoFinder clustering results directory                                  |
| `pfams_per_orthogroup.tsv`                | Merged PFAM domain and orthogroup membership table                        |
| `pannzer_results/`                        | Functional annotations from PANNZER2 (CSV per genome)                     |
| `pannzer_cleaned/`                        | Cleaned `gene2go.tsv` tables per genome extracted from PANNZER2           |
| `all_gene2go.tsv`                         | Unified gene-to-GO mapping for all genomes                                |
| `orthogroup_pangenome_classification.tsv` | Counts of core/accessory/exclusive genes per orthogroup                   |
| `topGO_inputs/`                           | Contains gene lists and gene2go inputs used for enrichment                |
| `topGO_results/`                          | topGO output tables per class (core, accessory, exclusive)                |
| `dotplot_core_GO_terms.png`               | Dotplot visualization of enriched GO terms in core genes                  |
| `dotplot_accessory_GO_terms.png`          | Dotplot visualization of enriched GO terms in accessory genes             |
| `dotplot_exclusive_GO_terms.png`          | Dotplot visualization of most frequent GO terms in exclusive genes        |
| `all_GO_terms_dotplot.tsv`                | Combined table used for GO dotplot generation                             |
| `top_GO_terms_summary.txt`                | Top 20 GO terms per class for biological interpretation                   |
| `revigo_input_core.tsv`                   | Input table for REVIGO using core enriched GO terms                       |
| `revigo_input_accessory.tsv`              | Input table for REVIGO using accessory enriched GO terms                  |
| `revigo_input_exclusive.tsv`              | Input table for REVIGO using top GO terms by frequency in exclusive genes |

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

### 10. Functional Annotation and Orthogroup Analysis
- Protein Domain Annotation (PFAM / HMMER)
  - ***Inputs:*** one .fa file per genome's predicted proteome.
  - ***Outputs:*** one .txt file per genome in hmmscan_results_cleaned/, using the --domtblout format.
  - Verified logs confirm correct output (e‑values, scores, multi‑domain hits).
```bash
# Scan protein FASTA files with PFAM-A HMM profiles
for fasta in proteins_fasta_cleaned/*.fa; do
  base=$(basename "$fasta" .fa)
  echo "Scanning $base with hmmscan"
  hmmscan \
    --cpu 2 \
    --domtblout hmmscan_results_cleaned/hmmscan_${base}.txt \
    Pfam-A.hmm \
    "$fasta"
done
```
Consolidation Script `parse_hmmscan_results.py` produces `all_pfams.tsv`: a unified table with all PFAM domains found across all genomes.

- Orthogroup Clustering (OrthoFinder)
  - Input directory (`files_for_orthofinder`)contains all .fa files of predicted proteins.
  - Output directory (`orthofinder_out`) holds results including `Orthogroups.tsv`.
  - `SequenceIDs.txt` and `SpeciesIDs.txt` confirm proper mapping between gene IDs and species FASTA files.

- Merging PFAM Domains with Orthogroups: `merge_pfams_orthogroups.py`
  - ***Output:***  `pfams_per_orthogroup.tsv`, combining PFAM domains with orthogroup membership and species labels.

### 11. Functional Annotation with PANNZER2 (Gene Ontology)
Step: Running PANNZER2 per genome
- One PANNZER2 run was launched per genome's predicted proteome.
- Each run generated multiple files, including:
  - HTML summaries for blocks of 1,000 queries.
  - Downloadable .csv files containing GO term predictions.

Output files per genome:
- `pannzer_results/*.csv`
Each file corresponds to one genome and contains multiple annotations per gene.

### 12. Extracting GO Terms from PANNZER2 Output
Script used: `extract_gene2go_from_pannzer.py`
  - Parses the .csv outputs from PANNZER2.
  - Filters and explodes GO terms from columns like MF_ARGOT, BP_ARGOT, etc.
  - Produces a 2-column TSV with gene ID and GO term ID.

Input:
- Folder `pannzer_results/` containing .csv files from each PANNZER2 run.

Output:
- Folder `pannzer_cleaned/`, containing one file per genome:
  - Format: `{species}_gene2go.tsv`

Combined Output:
  - `all_gene2go.tsv` — Unified table with all genes and their GO annotations across genomes.

### 13. Creating Gene Lists by Pangenome Class
Script used: `generate_gene_lists_by_class.py`
  - Maps genes to their corresponding orthogroup using `Orthogroups.tsv`.
  - Cross-references orthogroups with class definitions from `orthogroup_pangenome_classification.tsv`.

Inputs:
  - `Orthogroups.tsv`
  - `orthogroup_pangenome_classification.tsv`

Output:
  - Folder `gene_lists_per_class/`
    - Files: `core_genes.txt`, `accessory.txt`, `exclusive_genes.txt` (each with gene IDs per class)
  - `background_gene_list.txt` — All genes with GO terms, for enrichment background.

### 14. Gene Ontology Enrichment Analysis with topGO
Script used: `topgo_enrichment_class.R`
(Executed separately for each class: core, accessory, exclusive)
  - Builds a topGOdata object per class.
  - Uses annFUN.gene2GO for gene-to-GO mapping.
  - Performs Classic Fisher's exact test with BH correction (FDR).
  - Ontology used: Biological Process (BP)

Input:
  - `gene_lists_per_class/` — Gene lists per class
  - `all_gene2go.tsv` — Gene to GO mapping

Output:
  - `topGO_results/`
    - Files: `topGO_BP_core.tsv`, `topGO_BP_accessory.tsv`, `topGO_BP_exclusive.tsv`

Note:
- For the exclusive class, no enriched terms were detected under default parameters.
- Additional relaxed versions were tested using smaller nodeSize and no FDR filter, but few terms were found.
- Top GO terms by frequency (not enrichment) were extracted for exclusive class.

### 15. Dotplot Visualization of Enriched GO Terms
Script used: `dotplot_GO_terms_by_class.py`
  - Loads filtered and merged GO term tables.
  - Computes -log10(FDR) and optionally GeneRatio.
  - Visualizes top 20 GO terms per class using seaborn.scatterplot.

Inputs:
  - `topGO_results/all_GO_terms_dotplot.tsv`

Outputs:
  - `dotplot_core_GO_terms.png`
  - `dotplot_accessory_GO_terms.png`
  - `dotplot_exclusive_GO_terms.png`

### 16. Exporting Top GO Terms for Biological Interpretation and REVIGO
Script used: `extract_top_GO_terms_and_REVIGO.py`
  - Extracts top 20 GO terms per class.
  - For enriched categories (core, accessory), ranks by FDR.
  - For exclusive (no enrichment), ranks by frequency in annotation.
Outputs:
  - `top_GO_terms_summary.txt` — Summary of top GO terms.
  - `revigo_input_core.tsv`, `revigo_input_accessory.tsv`, `revigo_input_exclusive.tsv` — TSV inputs for uploading to REVIGO.

### Summary Outputs & Visualization of functional annotation and orthogroup analysis
- `class_summary.tsv`: summarizes counts of orthogroups per category (core, accessory, exclusive).
- `gene_matrix.tsv` and `gene_presence.tsv`: presence/absence matrices across samples.
- `plot_class_stats.py` produces barplot/pie-chart summaries of genes per class and domains by class (e.g., `barplot_genes_per_class.png`, `piechart_genes_per_class.png`).

This section concludes the functional annotation and clustering workflow, linking protein domains to orthogroup categories for downstream enrichment and evolutionary analyses.

### 17. Codon-Aware Sequence Alignment for dN/dS Analysis
**Goal:** Prepare codon-based multiple alignments per orthogroup for evolutionary analysis.

**Input:**
  - `cds_by_orthogroup/` — FASTA files of codon sequences per orthogroup (18,818 files), generated using GFF and FASTA annotations.

  **Step 1: Split into Chunks for Cluster Execution**
  **Script used:** `split_fasta_chunks.py`
    This script organizes the 18,818 `.fa` files into 38 balanced subdirectories:

   - `cds_by_orthogroup_chunks/chunk_001/` ... `chunk_038/`
    Each chunk contains \~495 FASTA files to allow parallel processing in the cluster.

### 18. Codon-Based Alignment with MAFFT
**Goal:** Perform codon-aware multiple sequence alignment using MAFFT for each orthogroup.
  **Execution:**
  -  **MAFFT version:** `7.487`

**Job script:** `run_mafft_chunks.sge`
Each task in the job array aligns all `.fa` files within a given chunk:

- `codon_alignments_chunks/chunk_001/*.fasta` ... `chunk_038/*.fasta`

**Output:**
  - `codon_alignments_chunks/` — Aligned FASTA files using `--thread 8`

### 19. Filtering Valid Alignments for dN/dS (Quality Control)
**Goal:** Remove alignments with internal stop codons or frame inconsistencies.

  **Script used:** `filter_clean_codon_alignments.py`
  This script:
    - Traverses all aligned `.fasta` files in `codon_alignments_chunks/`
    - Validates that:
      - All sequences are of equal length
      - Length is a multiple of 3
      - No internal stop codons (`TAA`, `TAG`, `TGA`) exist in frame
      - Copies valid alignments to: `codon_alignments_cleaned/`

**Output:**
  - `codon_alignments_cleaned/` — Cleaned alignments ready for tree/dN/dS analysis
  - `valid_codon_alignments.txt` — List of orthogroups passing quality filters (9,220 files)
  - 
### 20. Phylogenetic Tree Construction with IQ-TREE
**Goal:** Generate one tree per valid orthogroup using codon-based models.
 - **Job script:** `run_iqtree_cleaned.sge`
SGE array job that:
- Iterates over each `.fasta` in `codon_alignments_cleaned/`
- Launches IQ-TREE with:
  * `-st CODON`
  * `-m GY`
  * `-nt 4`

**Output:**
  -  `iqtree_results_cleaned/OG000XXXX/OG000XXXX.treefile` — One tree per orthogroup
  - Log and model selection files for each alignment

---

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
- ***VG toolkit:*** graph construction and analysis (GitHub)
- ***DIAMOND:*** ultra-fast protein aligner (GitHub)
- ***HMMER (hmmscan):*** PFAM domain search (hmmer.org)
- ***OrthoFinder:*** orthogroup clustering (GitHub)
- ***PANNZER2:*** functional annotation via GO terms (GitHub)
- ***Python 3:*** data parsing and visualization (pandas, matplotlib, seaborn)
- ***R:*** GO term enrichment analysis with packages:
- ***topGO:*** GO enrichment (Classic Fisher, BH correction)
- ***GO.db:*** ontology graph and term mapping
- ***gffread:*** GFF processing and transcript extraction
- ***Shell scripting:*** automation of batch processing and data formatting
