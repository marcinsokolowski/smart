#!/bin/bash -l

# test script flagging all tiles and checking noise stat :
# sbatch -p workq -M $sbatch_cluster pawsey_flag_test.sh   
# 

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=120gb
#SBATCH --output=./smart.o%j
#SBATCH --error=./smart.e%j
#SBATCH --export=NONE
echo "source $HOME/smart/bin/$COMP/env"
source $HOME/smart/bin/$COMP/env

which cotter
echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"

casa_ms=1226062160_20181112130910.ms
if [[ -n "$1" && "$1" != "-" ]]; then
   casa_ms=$1
fi

n_ant=128
if [[ -n "$2" && "$2" != "-" ]]; then
   n_ant=$2
fi

ant=0
while [[ $ant -lt $n_ant ]];
do
   ant_str=`echo $ant | awk '{printf("%03d",$1);}'`
   subdir=$ant_str
   base=${casa_ms%%.ms}
   
   echo   
   echo "Flagging antenna $ant -> in subdir $subdir"
   mkdir -p ${subdir}
   
   echo "cp -a ${casa_ms} ${subdir}/"
   cp -a ${casa_ms} ${subdir}/
   
   cd ${subdir}/
   echo "flagdata(vis='${casa_ms}',antenna='$ant')" > flag.py
   cat flag.py
   echo "casapy --no-logger -c flag.py"
   casapy --no-logger -c flag.py 
   
   echo "srun time /pawsey/mwa_sles12sp4/apps/cascadelake/gcc/8.3.0/wsclean/2.9/bin/wsclean -name ${base}_flagged_ant${ant_str} -j 6 -size 2048 2048   -pol XX,YY -abs-mem 128 -weight briggs -1 -scale 0.0401 -nmiter 1 -niter 0 -threshold 0.050 -mgain 0.85 -minuv-l 30 -join-polarizations ${casa_ms}"
   srun time /pawsey/mwa_sles12sp4/apps/cascadelake/gcc/8.3.0/wsclean/2.9/bin/wsclean -name ${base}_flagged_ant${ant_str} -j 6 -size 2048 2048   -pol XX,YY -abs-mem 128 -weight briggs -1 -scale 0.0401 -nmiter 1 -niter 0 -threshold 0.050 -mgain 0.85 -minuv-l 30 -join-polarizations ${casa_ms}

   echo "calcfits_bg ${base}_flagged_ant${ant_str}-XX-dirty.fits s > ${base}_flagged_ant${ant_str}.stat"
   calcfits_bg ${base}_flagged_ant${ant_str}-XX-dirty.fits s > ${base}_flagged_ant${ant_str}.stat
   
   echo "rm -fr ${casa_ms}"
   rm -fr ${casa_ms}
   
   cd ..
   
   ant=$(($ant+1))
done
 