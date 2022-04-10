#!/bin/bash

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --tasks-per-node=1
#SBATCH --mem=120gb
#SBATCH --output=./cotter_wsclean.o%j
#SBATCH --error=./cotter_wsclean.e%j
#SBATCH --export=NONE


# salloc --partition gpuq --time 23:59:00 --gres=gpu:1 --nodes=1

module purge
module load cascadelake/1.0 slurm/20.02.3 gcc/8.3.0 
module use /astro/mwavcs/pacer_blink/software/sles12sp5/modulefiles/
module load cotter/devel wsclean/devel mscommonlib/devel 
module load cotter_wsclean/devel
    
obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

calid=1274143032
if [[ -n "$2" && "$2" != "-" ]]; then
   calid=$2
fi

timestep_file=test.txt
if [[ -n "$3" && "$3" != "-" ]]; then
   timestep_file=$3
fi

visdir=/astro/mwavcs/msok/mwa/1274143152/10ms/vis/
if [[ -n "$4" && "$4" != "-" ]]; then
   visdir="$4"
fi

# -N to turn off cotter

for timestep in `cat ${timestep_file}`
do
   # creating symbolic links to GPUBOX files :
   for gpubox_file in `ls ${visdir}/${obsid}_${timestep}_gpubox*.fits`
   do
      echo "ln -s ${gpubox_file}"
      ln -s ${gpubox_file}
   done

   start=`date +%s`
   echo "srun /astro/mwavcs/msok/blink/bin/cotter_wsclean -d ./ -o ${obsid} -c ${calid} -t $timestep -T idg -C cotter_wsclean.config"
   srun /astro/mwavcs/msok/blink/bin/cotter_wsclean -d ./ -o ${obsid} -c ${calid} -t $timestep -T idg -C cotter_wsclean.config
   end=`date +%s`
   diff=$(($end-$start))
   echo "COTTER_WSCLEAN took : $diff [seconds]"
   
#   if [[ -s ${obsid}_flags.py ]]; then
#      echo "casapy -c ${obsid}_flags.py"
#      casapy -c ${obsid}_flags.py
#   else
#      echo "WARNING : file ${obsid}_flags.py -> no antenna flagging !!!"
#   fi
   
   echo "rm -f ${obsid}_${timestep}_gpubox*.fits"
   rm -f ${obsid}_${timestep}_gpubox*.fits
done
