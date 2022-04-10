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
#SBATCH --mem=120gb
#SBATCH --output=./pawsey_10ms_metafits.o%j
#SBATCH --error=./pawsey_10ms_metafits.e%j
#SBATCH --export=NONE


for ms in `ls -d *.ms`
do
   b=${ms%%.ms}
   
   t=`echo $ms | cut -b 12-25`
   
   awk -v ms=${ms} '{printf("flagdata(vis=\047%s\047,antenna=\047%s\047)\n",ms,$1);}' flagged_tiles.txt > ${b}.py
   
   echo "casapy --no-logger -c ${b}.py"   
done
