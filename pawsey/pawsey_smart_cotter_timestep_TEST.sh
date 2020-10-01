#!/bin/bash -l

# TODO : check account to use 

# Cotter the data
#SBATCH --account=pawsey0348
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=64gb
#SBATCH --output=/astro/mwaops/msok/log/smart/smart.o%j
#SBATCH --error=/astro/mwaops/msok/log/smart/smart.e%j
#SBATCH --export=NONE


# requirements :
# 1/ proper metafits file with NCHANS, NSCANS and INTTIME set properly - otherwise cotter will protest !!!
#    for all 4second observations from Nick : python /home/msok/bighorns/software/analysis/scripts/python/fix_metadata.py 1150234552.metafits --inttime=4 --n_scans=320 --n_channels=768
#    to process a single 4second :  python /home/msok/bighorns/software/analysis/scripts/python/fix_metadata.py 1150234552.metafits --inttime=4 --n_scans=1 --n_channels=768

# script converts every timestamp into a separate CASA measurements set and applies calibration and images
# mwa-process02 version : scp msok@mwa-process02:~/D0005/msok/asvo/202002/1150234232/data/all/smart_cotter_image_all.sh smart_cotter_image_all.sh.mwa02
# 


# sleep 120
# nohup cotter -absmem 64 -j 12 -timeres 4 -freqres 0.01 -noflagautos  -m 1150234552.metafits -norfi -noflagmissings -allowmissing -offline-gpubox-format -o 1150234552.ms 1150234552_*_??.fits > cotter.out 2>&1 &
# casapy -c apply_custom_cal.py 1150234552.ms 1150234232.cal 
# casapy -c image_tile_auto.py --imagesize=2048 1150234552.ms

export SMART_DIR=$HOME/smart/

timestamp=20160617213542
if [[ -n "$1" && "$1" != "-" ]]; then
   timestamp=$1
fi

do_scp=1
if [[ -n "$2" && "$2" != "-" ]]; then
   do_scp=$2
fi

do_remove=1
if [[ -n "$3" && "$3" != "-" ]]; then
   do_remove=$3
fi

# /astro/mwaops/vcs/1255444104/vis 
galaxy_path=/astro/mwaops/vcs/1150234552/vis
if [[ -n "$4" && "$4" != "-" ]]; then
   galaxy_path=$4
fi

obsid=1150234552
if [[ -n "$5" && "$5" != "-" ]]; then
   obsid=$5
fi

calid=1150234232
if [[ -n "$6" && "$6" != "-" ]]; then
   calid=$6
fi
cal=${calid}.cal


object="00h34m21.83s -05d34m36.72s" # PSRJ            J0034-0534 , S150            265.3
# object="00h36m08.95s -10d34m00.3s" # candidate 
# object="00h34m08.9s -07d21m53.409s" # J0034 for a test
if [[ -n "$7" && "$7" != "-" ]]; then
   object=$7
fi

beam_corr_type="image"
if [[ -n "$8" && "$8" != "-" ]]; then
   beam_corr_type=$8
fi

imagesize=2048
if [[ -n "$9" && "$9" != "-" ]]; then
   imagesize=$9
fi


force=0

echo "#############################################"
echo "PARAMETERS :"
echo "#############################################"
echo "do_scp      = $do_scp"
echo "do_remove   = $do_remove"
echo "galaxy_path = $galaxy_path"
echo "obsid       = $obsid"
echo "calid       = $calid"
echo "object      = $object"
echo "beam_corr_type = $beam_corr_type"
echo "#############################################"


change_phase_center=1

cp $SMART_DIR/bin/image_tile_auto.py .
cp $SMART_DIR/bin/apply_custom_cal.py .

# for timestamp in `cat timestamps.txt`
# do
   echo
   date
   
   ms_b=${obsid}_${timestamp}
   bname=wsclean_${ms_b}_briggs
   out_basename=${bname}-image
   out_basename_dirty=${bname}-dirty
   casa_ms=${obsid}_${timestamp}.ms
   # wsclean_1255444104_20191018143042_full-XX-dirty.fits
#   wsclean_fits_file=wsclean_${obsid}_${timestamp}_full-XX-dirty.fits
   wsclean_fits_file=${bname}-XX-dirty.fits
   
   if [[ ( -s ${out_basename}_V.fits || -s ${out_basename_dirty}_V.fits) && $force -le 0 ]]; then
      echo "Timestamp $timestamp / $ms_b / $out_basename already processed -> skipped"
   else
      if [[ ! -s ${wsclean_fits_file}  ]]; then
         echo "File ${wsclean_fits_file} does not exist -> processing"
         if [[ ! -d ${obsid}_${timestamp}.ms ]]; then
            if [[ $do_scp -gt 0 ]]; then 
               echo "rsync -avP ${galaxy_path}/${obsid}_${timestamp}*.fits ."
               rsync -avP ${galaxy_path}/${obsid}_${timestamp}*.fits .
            fi
   
            echo "cotter -absmem 64 -j 12 -timeres 4 -freqres 0.01 -noflagautos  -m ${timestamp}.metafits -norfi -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -o ${obsid}_${timestamp}.ms ${obsid}_${timestamp}*gpubox*.fits"
            cotter -absmem 64 -j 12 -timeres 4 -freqres 0.01 -noflagautos  -m ${timestamp}.metafits -norfi -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -o ${obsid}_${timestamp}.ms ${obsid}_${timestamp}*gpubox*.fits   

            if [[ -d ${obsid}_${timestamp}.ms ]]; then   
               date   
               echo "flagdata('${obsid}_${timestamp}.ms',mode='unflag')" > unflag.py
#               echo "casapy -c unflag.py"
#               casapy -c unflag.py 
      
               date   
               echo "casapy -c $SMART_DIR/bin/apply_custom_cal.py ${obsid}_${timestamp}.ms ${cal}"
               casapy -c $SMART_DIR/bin/apply_custom_cal.py ${obsid}_${timestamp}.ms ${cal}
      
              if [[ $do_remove -gt 0 ]]; then
                  echo "rm -fr ${obsid}_${timestamp}*.fits"
                  rm -fr ${obsid}_${timestamp}*.fits
              else
                  echo "WARNING : remove is not required (may produce a lot of data) !"
              fi
           else
               echo "WARNING : CASA ms already exists -> skipped"
           fi

            if [[ $change_phase_center -gt 0 ]]; then
               date
                 echo "chgcentre ${casa_ms} ${object}"
                 chgcentre ${casa_ms} ${object}
               date
            fi
         
            date
#    echo "casapy -c image_tile_auto.py --imagesize=2048 ${obsid}_${timestamp}.ms"
#    casapy -c image_tile_auto.py --imagesize=2048 ${obsid}_${timestamp}.ms   

            echo "$SMART_DIR/bin/wsclean_auto.sh ${obsid}_${timestamp}.ms - 0 ${beam_corr_type} ${imagesize}"
            $SMART_DIR/bin/wsclean_auto.sh ${obsid}_${timestamp}.ms - 0 ${beam_corr_type} ${imagesize}
         else
            echo "ERROR : CASA measurements set ${obsid}_${timestamp}.ms not created"
         fi   
      else
         echo "Image $wsclean_fits_file already exists -> skipped"
      fi

      echo "rm -fr ${obsid}_${timestamp}.ms ${obsid}_${timestamp}.ms.flag*"
      rm -fr ${obsid}_${timestamp}.ms ${obsid}_${timestamp}.ms.flag*   
   fi   
   touch ${wsclean_fits_file}
# done
