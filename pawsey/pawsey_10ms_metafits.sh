#!/bin/bash

# INFO :
#   --tasks-per-node=8 means that so many instances of the program will be running on a single node - NOT THREADS for THREADS use : --cpus-per-node=8
# #SBATCH --mem=100gb
#   --cpus-per-task=8 - number of CPUs per task/program (i.e. number of threads)

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --tasks-per-node=1
#SBATCH --mem=2gb
#SBATCH --output=./pawsey_10ms_metafits.o%j
#SBATCH --error=./pawsey_10ms_metafits.e%j
#SBATCH --export=NONE


for metafits in `ls *.metafits`
do
   echo "python ./fix_selected_metadata.py ${metafits} --n_scans=100 --inttime=0.01"
   python ./fix_selected_metadata.py ${metafits} --n_scans=100 --inttime=0.01
done
