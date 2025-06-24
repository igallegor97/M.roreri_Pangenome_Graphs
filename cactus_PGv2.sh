#!/bin/bash

#$ -q all.q
#$ -cwd
#$ -pe smp 20
#$ -l hostname=neotera

module load singularity-ce/3.11.2

taskset -c 0-${NSLOTS} singularity exec -H $(pwd) cactus_v2.9.9.sif cactus-pangenome ./tt_v2 data/Mror_Genomes.txt --outDir results_v2/cactus_out --logFile PGv2.log --outName Mror_Pangenome_v1 --reference Mror_1466_REFE --giraffe --viz --odgi --chrom-vg --chrom-og --gbz --gfa --vcf --workDir tempdir/
