#!/bin/bash -l 

#$ -l h_rt=120:00:00

#$ -l mem_total=125G -pe omp 16

#$ -N DNA_contigs

#$ -m ae

# A simple loop to serially map all samples.
# referenced from within http://merenlab.org/tutorials/assembly_and_mapping/

cd /usr4/spclpgm/bhackos

#set directory where contig files are stored
cd /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/

# read in the file in directory with contigs.fa
#contig.file <- read.delim("fileName"")

# set a path for where things should download

#load necessary modules
module load miniconda/4.5.12
conda activate /projectnb/talbot-lab-data/NEFI_data/metagenomes/conda_env/anvio5
module load bowtie2
module load samtools

# loop through list of contigs
  i <- 1
  while (i < 35) {
   
    contig <- contig.file[i, 1]
    SAMPLE <- as.character(substr(contig, 1, 19))
    read1 -> "-comp_1.fastq"
    read2 -> "-comp_2.fastq"
    directory -> paste0("/projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/03_CONTIGS/", SAMPLE)
    
    bowtie2-build /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/03_CONTIGS/SAMPLE /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/04_MAPPING/contigs1
    i = i+1
  }

bowtie2 --threads 4 -x /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/04_MAPPING/contigs1 -1 /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/01_QC/cleaned/BART_004-O-20140619-comp_1.fastq -2 /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/01_QC/cleaned/BART_004-O-20140619-comp_2.fastq -S /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/04_MAPPING/BART_004-O-20140619.sam

samtools view -F 4 -bS /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/04_MAPPING/BART_004-O-20140619.sam > 04_MAPPING/BART_004-O-20140619-RAW.bam

anvi-init-bam 04_MAPPING/BART_004-O-20140619-RAW.bam -o 04_MAPPING/BART_004-O-20140619.bam

rm 04_MAPPING/BART_004-O-20140619.sam 04_MAPPING/BART_004-O-20140619.bam