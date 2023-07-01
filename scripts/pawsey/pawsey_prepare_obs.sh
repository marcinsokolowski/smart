#!/bin/bash -l

# WARNING : programs azh2radec and date2date are probably not compiled on galaxy/magnus ..., but I can do it ...

#SBATCH --account=pawsey0348
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=16gb
#SBATCH --output=/astro/mwaops/msok/log/smart/smart.o%j
#SBATCH --error=/astro/mwaops/msok/log/smart/smart.e%j
#SBATCH --export=NONE

if [[ -s $HOME/smart/bin/magnus/env ]]; then
   echo "source $HOME/smart/bin/magnus/env"
   source $HOME/smart/bin/magnus/env
else
   echo "WARNING : file $HOME/smart/bin/magnus/env not found -> most likely non-PAWSEY system"
fi

smart_bin=$SMART_DIR/bin/


obsid=1275258616
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

calid=1275258360
if [[ -n "$2" && "$2" != "-" ]]; then
   calid=$2
fi

metafits_dir=/media/msok/0754e982-0adb-4e33-80cc-f81dda1580c8/mwa/smart/202002/202006
if [[ -n "$3" && "$3" != "-" ]]; then
   metafits_dir=$3
fi

remote_dir=/group/mwasci/msok/test/202002/${obsid}/
if [[ -n "$4" && "$4" != "-" ]]; then
   remote_dir=$4
fi


force=0

echo "mkdir -p ${metafits_dir}/${obsid}"
mkdir -p ${metafits_dir}/${obsid}

if [[ -d ${metafits_dir}/${obsid} ]]; then
   cd ${metafits_dir}/${obsid}

   if [[ ! -s ${calid}.bin || $force -gt 0 ]]; then
      # download calibration and plot :
      echo "smart_getcal.sh ${calid}"
      smart_getcal.sh ${calid}

      if [[ -s solutions.zip ]]; then
         echo "unzip solutions.zip"
         unzip solutions.zip
   
         echo "check_solutions.sh ${calid}.bin ${calid}"
         check_solutions.sh ${calid}.bin ${calid}
      else
         echo "ERROR : solutions.zip does not exist -> cannot continue"
         exit
      fi
   else
      echo "INFO : binary file ${calid}.bin already exists -> not getting / plotting calibration (use force=1 to re-download and re-plot)"
   fi
   
#   if [[ ! -s ${calid}_flagged_tiles.txt ]]; then
#      echo "ERROR : file ${calid}_flagged_tiles.txt does not exist -> please verify and restart with option force=1"
#      exit;
#   else
#      echo "rsync -avP ${calid}_flagged_tiles.txt galaxy:${remote_dir}/flagged_tiles.txt"
#      rsync -avP ${calid}_flagged_tiles.txt galaxy:${remote_dir}/flagged_tiles.txt
#   fi


   # prepare metafits files :
   echo "pawsey_smart_prepare_timestamps.sh ${obsid}"
   pawsey_smart_prepare_timestamps.sh ${obsid}

   echo "DO : cd ${metafits_dir}/${obsid}"
else
   echo "ERROR : could not create directory ${metafits_dir}/${obsid}"
fi
