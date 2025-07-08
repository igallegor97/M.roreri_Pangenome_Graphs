## This script downloads the genomes, splits them into chromosomes and creates sourmash signatures and indexes

#!/bin/bash

#$ -q all.q
#$ -cwd

module load miniconda3

for FASTA in $(grep content data.json|grep groups.fasta|grep -v gz|sed 's/content\t//'|sed  's/"//g'); do 
 STRAIN=${FASTA#https://zenodo.org/api/records/7872498/files/}; 
 STRAIN=${STRAIN/.groups.fasta}; 
 STRAIN=${STRAIN/\/content};
 STRAIN2=${STRAIN/Mror/Mror_};
 echo $STRAIN $STRAIN2; 
 OUTFILE=${STRAIN2}.pacbio.fasta; 
 echo $OUTFILE; 
 if [ -f $OUTFILE ]; then
    echo "File $OUTFILE already exists, skipping download."
 else
    echo "Downloading $OUTFILE"
    wget -O ${OUTFILE} $FASTA; 
    sed -i "s/>${STRAIN}/>${STRAIN2}/" ${OUTFILE}; 
    mkdir -p $STRAIN2; 
    cp ${OUTFILE} $STRAIN2; 
    cd $STRAIN2; 
    module load EMBOSS/6.6.0
    seqretsplit -auto ${OUTFILE} 
    rm ${OUTFILE}
    cd ..
    module unload EMBOSS/6.6.0
 fi
 mkdir -p sourmarsh_sigs
 module load sourmash
 echo  "computing sourmash signature for $STRAIN2"
 sourmash sketch dna -p scaled=1000,k=31 --outdir sourmarsh_sigs $STRAIN2/*.fasta
 module unload sourmash
done

module load sourmash
sourmash index moniliophthora_pacbio_db sourmarsh_sigs
mkdir -p sourmarsh_comps/
 echo  "computing sourmash index"
for sig in  sourmarsh_sigs/*.sig; do
 outfile=`basename $sig`
 outfile=${outfile/.sig/.sourmash.search.txt}
 echo  "computing sourmash containment for $sig"
 sourmash search $sig sourmarsh_sigs/ -o sourmarsh_comps/$outfile -n 0
done
