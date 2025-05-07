#!/bin/bash


#$ -q all.q
#$ -cwd
#$ -pe smp 10 
#$ -t 1

module load singularity-ce/3.11.2

singularity exec -H $(pwd) docker://quay.io/comparative-genomics-toolkit/cactus:v2.9.8 cactus-pangenome ./tt data/Mror_Genomes.txt --outDir results/cactus_out --outName Mror_Pangenome_v1 --reference Mror_1466_REFE --giraffe --viz --odgi --chrom-vg --chrom-og --gbz --gfa --vcf --workDir tempdir/ --consCores 10 --mgMemory 100Gi
