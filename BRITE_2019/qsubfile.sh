
#!/bin/bash -l

#$ -l h_rt=120:00:00

#$ -l mem_total=125G -pe omp 16

#$ -N DNA_decontam

#$ -m ae

sunbeam run -- --configfile /projectnb/talbot-lab-data/NEFI_data/my_project/sunbeam_config.yml all_decontam


