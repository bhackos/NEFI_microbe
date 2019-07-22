
#!/bin/bash -l

#$ -l h_rt=120:00:00

#$ -l mem_total=125G -pe omp 16

#$ -N DNA_assembly

#$ -m ae

cd /usr4/spclpgm/bhackos

module load miniconda/4.5.12

source activate sunbeam-tmp.pkm3BCVHjt

unset PYTHONPATH

sunbeam run -- --configfile /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/sunbeam_config.yml --unlock co_assembly

sunbeam run -- --configfile /projectnb/talbot-lab-data/NEFI_data/metagenomes/my_project_short/sunbeam_config.yml co_assembly


