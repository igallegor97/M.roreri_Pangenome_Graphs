## Results from the categories extracted from Gus scripts

<img width="1072" height="900" alt="image" src="https://github.com/user-attachments/assets/c60fd36f-2d6f-4a4b-bb98-aaf30afcfc61" />
<img width="608" height="548" alt="image" src="https://github.com/user-attachments/assets/027e2762-a487-4a53-9c70-4389e5f681c0" />
<img width="608" height="548" alt="image" src="https://github.com/user-attachments/assets/f9c115e3-d713-4876-8915-f3c4c1021c54" />

## Results from Orthofinder (compared to orthologue-based pangenome):

## Comparative Summary: Orthology-based vs Graph-based Pangenome of *Moniliophthora roreri*

This table summarizes the key metrics from two complementary pangenome strategies applied to *M. roreri*. The orthology-based pangenome was constructed using 22 Illumina-assembled genomes, while the graph-based pangenome was built with 5 high-quality PacBio genomes using the Cactus-Minigraph pipeline. Orthogroup inference in both cases was performed with OrthoFinder.

| Metric                                    | Orthology-based Pangenome (22 genomes, Illumina) | Graph-based Pangenome (5 genomes, PacBio) | Interpretation |
|------------------------------------------|--------------------------------------------------|-------------------------------------------|----------------|
| Total number of genes in orthogroups     | 444,887                                          | 103,487                                   | Comparable gene counts per genome (~20k) confirm annotation consistency |
| Average genes per genome in orthogroups  | 20,222                                           | 20,697                                    | Indicates consistent genome annotation and completeness |
| Number of orthogroups                    | 28,215                                           | 19,831                                    | More orthogroups in larger dataset due to increased accessory and unique genes |
| % of orthogroups recovered in graph-based set | -                                            | 70.3%                                     | The graph-based pangenome captures ~70% of the diversity seen in the full 22-genome Illumina set |
| Average genes per orthogroup             | 15.77                                            | 5.22                                      | Smaller average reflects fewer genomes, leading to fewer multi-copy orthogroups |

### Notes:
- The larger number of orthogroups in the 22-genome set is expected due to higher genomic diversity and inclusion of more unique and accessory genes.
- The graph-based pangenome, although built with fewer genomes, provides high-contiguity assemblies, leading to more accurate and less fragmented orthogroups.
- The ~70% overlap suggests that the core genome and a large portion of the accessory genome are recoverable with just five high-quality PacBio genomes.

