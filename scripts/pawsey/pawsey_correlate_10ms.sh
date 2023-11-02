#!/bin/bash

# INFO :
#   --tasks-per-node=8 means that so many instances of the program will be running on a single node - NOT THREADS for THREADS use : --cpus-per-node=8
# #SBATCH --mem=100gb
#   --cpus-per-task=8 - number of CPUs per task/program (i.e. number of threads)

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

obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

calid=1274143032
if [[ -n "$2" && "$2" != "-" ]]; then
   calid=$2
fi

gpstime=$obsid
if [[ -n "$3" && "$3" != "-" ]]; then
   gpstime=$3
fi
uxtime=$(($gpstime+315964782))

n_timesteps=1
if [[ -n "$4" && "$4" != "-" ]]; then
   n_timesteps=$4
fi

start_ch=132
if [[ -n "$5" && "$5" != "-" ]]; then
   start_ch=$5
fi
end_ch=$(($start_ch-24+1))

echo "#################################"
echo "PARAMETERS:"
echo "#################################"
echo "obsid = $obsid"
echo "gpstime = $gpstime -> uxtime = $uxtime"
echo "calid = $calid"
echo "n_timesteps = $n_timesteps"
echo "start_ch    = $start_ch -> end_ch = $end_ch"
echo "#################################"

source /astro/mwavcs/msok/blink/cotter_wsclean/env/garrawarla.env


gpsend=$(($gpstime+$n_timesteps))

path=/astro/mwavcs/msok/blink/vcsbeam/build/offline_correlator/offline_correlator

while [[ $gpstime -lt $gpsend ]];
do
   uxtime=$(($gpstime+315964782))

   # WARNING : had to remove option -i 100 with respect to working version as in : /astro/mwavcs/msok/mwa/1276619416/Offline_correlator/vcs_process_options/
   # echo "$path -o ${obsid} -s ${uxtime} -r 100 -n 4 -c ${ch_out_str} -d /astro/mwavcs/vcs/${obsid}/combined/${obsid}_${gpstime}_ch${ch}.dat"
   # $path -o ${obsid} -s ${uxtime} -r 100 -n 4 -c ${ch_out_str} -d /astro/mwavcs/vcs/${obsid}/combined/${obsid}_${gpstime}_ch${ch}.dat

 
   ch=$end_ch
   ch_out=1
   while [[ $ch -le 128 ]];
   do
      ch_out_str=`echo $ch_out | awk '{printf("%02d",$1);}'`


      # WARNING : had to remove option -i 100 with respect to working version as in : /astro/mwavcs/msok/mwa/1276619416/Offline_correlator/vcs_process_options/
      # -i 1
      echo "$path -o ${obsid} -s ${uxtime} -r 100 -n 4 -c ${ch_out_str} -d /astro/mwavcs/vcs/${obsid}/combined/${obsid}_${gpstime}_ch${ch}.dat"
      $path -o ${obsid} -s ${uxtime} -r 100 -n 4 -c ${ch_out_str} -d /astro/mwavcs/vcs/${obsid}/combined/${obsid}_${gpstime}_ch${ch}.dat
   

      ch=$(($ch+1))
      ch_out=$(($ch_out+1))
   done

   ch=$start_ch
   while [[ $ch -gt 128 ]];
   do
      ch_out_str=`echo $ch_out | awk '{printf("%02d",$1);}'`


      # WARNING : had to remove option -i 100 with respect to working version as in : /astro/mwavcs/msok/mwa/1276619416/Offline_correlator/vcs_process_options/
      # -i 1
      echo "$path -o ${obsid} -s ${uxtime} -r 100 -n 4 -c ${ch_out_str} -d /astro/mwavcs/vcs/${obsid}/combined/${obsid}_${gpstime}_ch${ch}.dat"
      $path -o ${obsid} -s ${uxtime} -r 100 -n 4 -c ${ch_out_str} -d /astro/mwavcs/vcs/${obsid}/combined/${obsid}_${gpstime}_ch${ch}.dat   

      ch=$(($ch-1))
      ch_out=$(($ch_out+1))
   done

   gpstime=$(($gpstime+1))
done   
