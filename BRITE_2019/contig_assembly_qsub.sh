#!/bin/bash -l 

#$ -l h_rt=120:00:00

#$ -l mem_total=125G -pe omp 16

#$ -N DNA_report

#$ -m ae

# A simple loop to serially map all samples.
# referenced from within http://merenlab.org/tutorials/assembly_and_mapping/

cd /usr4/spclpgm/bhackos

cd /projectnb/talbot-lab-data/NEFI_data/my_project2

module load miniconda/4.5.12

module load bowtie2 

# how many threads should each mapping task use?
NUM_THREADS=4

for sample in `awk '{print $1}' samples.txt`
do
    if [ "$sample" == "sample" ]; then continue; fi
    
    # you need to make sure you "ls 01_QC/*QUALITY_PASSED_R1*" returns R1 files for all your samples in samples.txt
    R1s=`ls 01_QC/$sample*QUALITY_PASSED_R1* | python -c 'import sys; print ",".join([x.strip() for x in sys.stdin.readlines()])'`
    R2s=`ls 01_QC/$sample*QUALITY_PASSED_R2* | python -c 'import sys; print ",".join([x.strip() for x in sys.stdin.readlines()])'`
    
    bowtie2 --threads $NUM_THREADS -x 04_MAPPING/contigs -1 $R1s -2 $R2s --no-unal -S 04_MAPPING/$sample.sam
    samtools view -F 4 -bS 04_MAPPING/$sample.sam > 04_MAPPING/$sample-RAW.bam
    anvi-init-bam 04_MAPPING/$sample-RAW.bam -o 04_MAPPING/$sample.bam
    rm 04_MAPPING/$sample.sam 04_MAPPING/$sample-RAW.bam
done

# mapping is done, and we no longer need bowtie2-build files
rm 04_MAPPING/*.bt2