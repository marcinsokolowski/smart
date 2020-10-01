#! /bin/bash -l
#SBATCH --export=NONE
#SBATCH -M zeus
#SBATCH -p workq
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=28

#ensure data is owned by mwasci
newgrp mwasci

base=BASEDIR
datadir="${base}/processing"
obsnum=OBSNUM
catfile=CATFILE
doaoflagger=AOFLAGGER


