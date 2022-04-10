#!/bin/bash -l

# START : sbatch -p gpuq -M $sbatch_cluster `which submit_cotter_wsclean.sh`

# INFO :
#   --tasks-per-node=8 means that so many instances of the program will be running on a single node - NOT THREADS for THREADS use : --cpus-per-node=8
# #SBATCH --mem=100gb
#   --cpus-per-task=8 - number of CPUs per task/program (i.e. number of threads)

# WARNING : amount of memory 160gb = 120gb for WSCLEAN/COTTER and 10gb for the situation with script is executed on /dev/shm/ (ramdisk)
#           be careful with this if NVMe or /tmp (also fast) are used this extra 10gb is not required 
#           also 10gb is sufficient for 1second CASA measurement sets and images, but may not be enough for larger datasets

#SBATCH --account=mwavcs
#SBATCH --time=23:59:59
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=6
#SBATCH --tasks-per-node=1
#SBATCH --mem=130gb
#SBATCH --output=./cotter_wsclean.o%j
#SBATCH --error=./cotter_wsclean.e%j
#SBATCH --export=NONE

obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

timestamp=20200522004234
if [[ -n "$2" && "$2" != "-" ]]; then
   timestamp=$2
fi

start=0
if [[ -s last_started.txt ]]; then
   start=`cat last_started.txt`
fi

mkdir -p ${timestamp}
cd ${timestamp}

echo "ln -s ../${obsid}_${timestamp}.ms"
ln -s ../${obsid}_${timestamp}.ms

while [[ $start -lt 100 ]];
do
   end=$(($start+1))
   start_str=`echo $start | awk '{printf("%03d",$1);}'`
   
   echo $start > last_started.txt

   start_ux=`date +%s`   

   echo "srun wsclean -name wsclean_${obsid}_${timestamp}_briggs_timeindex${start_str} -j 6 -size 4096 4096 -pol XX,YY -abs-mem 120 -weight briggs -1 -scale 0.0047 -niter 0 -minuv-l 30 -join-polarizations -interval $start $end ${obsid}_${timestamp}.ms"
   srun wsclean -name wsclean_${obsid}_${timestamp}_briggs_timeindex${start_str} -j 6 -size 4096 4096 -pol XX,YY -abs-mem 120 -weight briggs -1 -scale 0.0047 -niter 0 -minuv-l 30 -join-polarizations -interval $start $end ${obsid}_${timestamp}.ms
   
   end_ux=`date +%s`
   diff=$(($end_ux-$start_ux))
   echo "WSCLEAN took $diff [seconds]"
   
   echo $start > last_finished.txt
   
   start=$(($start+1))
done
   
date > done.txt
