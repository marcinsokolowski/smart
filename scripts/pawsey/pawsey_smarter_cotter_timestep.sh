#!/bin/bash -l

# sbatch -p workq -M $sbatch_cluster pawsey_smarter_cotter_timestep.sh 1 1  /astro/mwavcs/vcs/1276619416/cal/1276619416/vis 1276619416 1276625432 "18h33m41.89s -03d39m04.25s" - 4096 test.txt 1

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 
# 
# INFO :
#   --tasks-per-node=8 means that so many instances of the program will be running on a single node - NOT THREADS for THREADS use : --cpus-per-node=8

#SBATCH --account=director2183
#SBATCH --time=23:59:59
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --tasks-per-node=1
#SBATCH --mem=120gb
#SBATCH --output=./smarter.o%j
#SBATCH --error=./smarter.e%j
#SBATCH --export=NONE

echo "source /group/director2183/software/env.sh"
source /group/director2183/software/env.sh

echo "module load cotter-wsclean-msok/devel"
module load cotter-wsclean-msok/devel

which cotter
echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"


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

# chgcentre_path=""
comp=`hostname`
if [[ $comp == "mwa-process02" ]]; then
   # specific for mwa-process02
   # chgcentre_path="/home/msok/mwa_software/anoko/anoko/chgcentre/build/"
   export PATH=/home/msok/mwa_software/anoko/anoko/chgcentre/build/:$PATH
fi
if [[ -n $cluster ]]; then
   echo "Cluster $cluster detected"
   comp=$cluster
fi


do_scp=1
if [[ -n "$1" && "$1" != "-" ]]; then
   do_scp=$1
fi

do_remove=1
if [[ -n "$2" && "$2" != "-" ]]; then
   do_remove=$2
fi
do_remove_gpufits=1

# /astro/mwaops/vcs/1255444104/vis 
#galaxy_path=/astro/mwaops/vcs/1150234552/vis
#if [[ $comp == "mwa-process02" ]]; then
#   galaxy_path=galaxy:/astro/mwaops/vcs/1150234552/vis
#fi
galaxy_path=""
obsid=1150234552
if [[ -n "$4" && "$4" != "-" ]]; then
   obsid=$4
fi
if [[ -n "$3" && "$3" != "-" ]]; then # SHOULD REALLY BE EARLIER BUT IS HERE TO BE ABLE TO USE DEFAULT LOCATION :
   galaxy_path=$3
else
   galaxy_path=/astro/mwaops/vcs/${obsid}/vis
fi

calid=1150234232
if [[ -n "$5" && "$5" != "-" ]]; then
   calid=$5
fi
cal=${calid}.cal

# object="00h34m21.83s -05d34m36.72s" # PSRJ            J0034-0534 , S150            265.
object="00h36m08.95s -10d34m00.3s" # candidate 
# object="00h34m08.9s -07d21m53.409s" # J0034 for a test
if [[ -n "$6" && "$6" != "-" ]]; then
   object=$6
fi

beam_corr_type="image"
if [[ -n "$7" && "$7" != "-" ]]; then
   beam_corr_type=$7
fi

imagesize=2048
if [[ -n "$8" && "$8" != "-" ]]; then
   imagesize=$8
fi

# timestamp=20160617213542
timestamp_file=timestamps.txt
if [[ -n "$9" && "$9" != "-" ]]; then
   timestamp_file=$9
fi

subdirs=1
if [[ -n "${10}" && "${10}" != "-" ]]; then
   subdirs=${10}
fi

is_last=0
if [[ -n "${11}" && "${11}" != "-" ]]; then
   is_last=${11}
fi

# 12 param skipped 

wsclean_type="standard"
if [[ -n "${13}" && "${13}" != "-" ]]; then
   wsclean_type=${13}
fi

wsclean_pbcorr=0
if [[ -n "${14}" && "${14}" != "-" ]]; then
   wsclean_pbcorr=${14}
fi

n_iter=10000 # 100000 too much 
if [[ -n "${15}" && "${15}" != "-" ]]; then
   n_iter=${15}
fi

wsclean_options=""
if [[ -n "${16}" && "${16}" != "-" ]]; then
   wsclean_options=${16}
fi

tmpdir="/tmp/cotter_wsclean/"
if [[ -n "${17}" && "${17}" != "-" ]]; then
   tmpdir=${17}
fi



peel_model_file="peel_model.txt"

edge=80 # or 160 kHz of excised edge channels ?

force=0

is_idg=`echo $wsclean_options | grep idg | wc -l`

echo "#############################################"
echo "PARAMETERS :"
echo "#############################################"
echo "timestamp_file  = $timestamp_file"
echo "do_scp          = $do_scp"
echo "do_remove       = $do_remove"
echo "galaxy_path     = $galaxy_path ( at computer = $comp )"
echo "obsid           = $obsid"
echo "calid           = $calid"
echo "object          = $object"
echo "beam_corr_type  = $beam_corr_type"
echo "timestamp_file  = $timestamp_file"
echo "computer        = $comp"
echo "subdirs         = $subdirs"
echo "is_last         = $is_last"
echo "edge            = $edge"
echo "peel_model_file = $peel_model_file"
echo "wsclean_type    = $wsclean_type"
echo "wsclean_pbcorr  = $wsclean_pbcorr"
echo "n_iter          = $n_iter"
echo "wsclean_options = $wsclean_options"
echo "is_idg          = $is_idg"
echo "tmpdir          = $tmpdir"
echo "#############################################"


original_dir=`pwd`

bin_file=""
use_casa_cal=1
if [[ ! -s ${calid}.cal ]]; then
   use_casa_cal=0
   echo "WARNING : ${calid}.cal does not exist - will try ASVO calibration database"

   ls -al *.bin
   bin_count=`ls *.bin | wc -l`

   if [[ $bin_count -le 0 ]]; then
      if [[ $calid -gt 0 ]]; then
         # http://mro.mwa128t.org/ -> wget "http://ws.mwatelescope.org/calib/get_calfile_for_calid?cal_id=${obs}" 
         # Does this one require a change ???
         echo "wget \"http://ws.mwatelescope.org/calib/get_calfile_for_calid?cal_id=${calid}\" -O solutions.zip"
         wget "http://ws.mwatelescope.org/calib/get_calfile_for_calid?cal_id=${calid}" -O solutions.zip
      else
         echo "wget \"http://ws.mwatelescope.org/calib/get_calfile_for_obsid?obs_id=${obsid}&zipfile=1&add_request=1${options}\" -O solutions.zip"   
         wget "http://ws.mwatelescope.org/calib/get_calfile_for_obsid?obs_id=${obsid}&zipfile=1&add_request=1${options}" -O solutions.zip
      fi

      if [[ -s solutions.zip ]]; then
         echo "DEBUG : cal solutions downloaded ok -> unzipping"
      else
         echo "WARNING : cal solutions for obsid=$obsid or calid=$calid not found in ASVO database -> submitting request"

         if [[ $calid -gt 0 ]]; then
            echo "wget \"http://ws.mwatelescope.org/calib/get_calfile_for_obsid?obs_id=${calid}&zipfile=1&add_request=1${options}\" -O solutions.zip"
            wget "http://ws.mwatelescope.org/calib/get_calfile_for_obsid?obs_id=${calid}&zipfile=1&add_request=1${options}" -O solutions.zip
         else
            echo "INFO : request should already be correctly submitted with the previous wget command"
         fi
      fi

      echo "unzip solutions.zip"
      unzip solutions.zip
            

      ls -al *.bin
      bin_count=`ls *.bin | wc -l`
      if [[ $bin_count -le 0 ]]; then
         echo "ERROR : cannot get calibration solutions nor CASA .cal exists -> exiting now"
         exit;
      else
         echo "INFO : calibration solutions found"
         
         bin_file=${calid}.bin
         if [[ -s ${bin_file} ]]; then
            echo "INFO : ${bin_file} exists -> it will be used"
         else
            echo "WARNING : ${bin_file} does not exist -> trying to use other bin file"
            bin_file=`ls *.bin | tail -1`

            echo "ln -s ${bin_file} ${calid}.bin"
            ln -s ${bin_file} ${calid}.bin
         fi
      fi
      
      if [[ -s flagged_tiles.txt ]]; then
         echo "INFO : file flagged_tiles.txt already exists (not overwritten)"
      else
         if [[ -s ${calid}_flagged_tiles.txt ]]; then
            echo "cp ${calid}_flagged_tiles.txt flagged_tiles.txt"
            cp ${calid}_flagged_tiles.txt flagged_tiles.txt
         else
            echo "WARNING : flagged tiles file ${calid}_flagged_tiles.txt not found -> please verify !!!"
         fi
      fi
   else
      echo "INFO : calibration solutions found (no wget needed)"
      bin_file=`ls *.bin | tail -1`

      echo "ln -s ${bin_file} ${calid}.bin"
      ln -s ${bin_file} ${calid}.bin
   fi
fi

echo "cp ${COTTER_WSCLEAN_CONFIG} ."
cp ${COTTER_WSCLEAN_CONFIG} .

for timestamp in `cat ${timestamp_file}`
do
   echo
   date

   wsclean_fits_file=${out_basename}_V.fits
   if [[ -d ${timestamp} && -s ${timestamp}/${wsclean_fits_file} ]]; then
      echo "INFO : directory ${timestamp} and file $wsclean_fits_file already exist -> skipped (continue)"
      continue;
   else
      echo "INFO : unprocessed timestamp -> processing now ..."
   fi
   
   if [[ $subdirs -gt 0 ]]; then
      mkdir -p ${timestamp}
      cd ${timestamp}
      
      # symbolic link to CASA-ms with calibration :
      if [[ -s ../${calid}.cal ]]; then
         echo "ln -s ../${calid}.cal"
         ln -s ../${calid}.cal
      else
         echo "WARNING : ../${calid}.cal does not exist"
      fi
      if [[ -s ../${calid}.bin ]]; then
         echo "ln -s ../${calid}.bin"
         ln -s ../${calid}.bin
      else
         echo "WARNING : ../${calid}.bin does not exist"
      fi
      if [[ -s ../${calid}.ms ]]; then 
         echo "ln -s ../${calid}.ms"
         ln -s ../${calid}.ms
      else
         echo "WARNING : ../${calid}.ms does not exist"
      fi
      
      ln -s ../${timestamp}.metafits
      ln -s ../data # for HDF5 2016 beam model file ...
   fi
   
   ms_b=${obsid}_${timestamp}
   bname=wsclean_${ms_b}_briggs
   out_basename=${bname}-image
   out_basename_dirty=${bname}-dirty
   casa_ms=${obsid}_${timestamp}.ms
   # wsclean_1255444104_20191018143042_full-XX-dirty.fits
#   wsclean_fits_file=wsclean_${obsid}_${timestamp}_full-XX-dirty.fits
#   wsclean_fits_file=${bname}-XX-dirty.fits
   
   if [[ ( -s ${out_basename}_V.fits || -s ${out_basename_dirty}_V.fits) && $force -le 0 ]]; then
      echo "Timestamp $timestamp / $ms_b / $out_basename already processed -> skipped"
   else
      if [[ ! -s ${wsclean_fits_file}  ]]; then
         echo "File ${wsclean_fits_file} does not exist -> processing"
         if [[ ! -d ${obsid}_${timestamp}.ms ]]; then
            # original_dir
            mkdir -p ${tmpdir}/
            cd ${tmpdir}/
            
            echo "rm -fr ${tmpdir}/*"
            rm -fr ${tmpdir}/*
            
            pwd
            echo "cp ${original_dir}/*.bin ."
            cp ${original_dir}/*.bin .
            
            echo "ln -s ${original_dir}/${timestamp}.metafits ."
            ln -s ${original_dir}/${timestamp}.metafits .
            
            echo "ln -s ${original_dir}/cotter_wsclean.config"
            ln -s ${original_dir}/cotter_wsclean.config 
         
            if [[ $do_scp -gt 0 ]]; then 
               echo "rsync -avP ${galaxy_path}/${obsid}_${timestamp}*.fits ."
               rsync -avP ${galaxy_path}/${obsid}_${timestamp}*.fits .
            fi
   
            date
            ls -al 
   
            # 2020-07-11 - -norfi removed 
            ux_start=`date +%s`
#            echo "$srun_command cotter -absmem 64 -j 12 -timeres 1 -freqres 0.01 -edgewidth ${edge} -noflagautos  -m ${timestamp}.metafits -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -full-apply ${bin_file} -centre ${object} -o ${obsid}_${timestamp}.ms ${obsid}_${timestamp}*gpubox*.fits"
#            $srun_command cotter -absmem 64 -j 12 -timeres 1 -freqres 0.01 -edgewidth ${edge} -noflagautos  -m ${timestamp}.metafits -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -full-apply ${bin_file} -centre ${object} -o ${obsid}_${timestamp}.ms ${obsid}_${timestamp}*gpubox*.fits   
            echo "srun cotter_wsclean -d "./" -o ${obsid} -c ${calid} -t ${timestamp} ${options} -C cotter_wsclean.config"
            srun cotter_wsclean -d "./" -o ${obsid} -c ${calid} -t ${timestamp} ${options} -C cotter_wsclean.config
            ux_end=`date +%s`
            ux_diff=$(($ux_end-$ux_start))
            echo "COTTER_WSCLEAN_TOTAL : ux_start = $ux_start , ux_end = $ux_end -> ux_diff = $ux_diff" > benchmarking.txt
 
            echo "PROGRESS : cleaning started at :"
            date           
            # remove GPU FITS files :
            echo "rm -fr ${obsid}_${timestamp}*.fits"
            rm -fr ${obsid}_${timestamp}*.fits
            
            mkdir -p ${original_dir}/${timestamp}/
            echo "mv ${tmpdir}/*image.fits ${original_dir}/${timestamp}/"
            mv ${tmpdir}/*image.fits ${original_dir}/${timestamp}/
            
            echo "rm -fr ${tmpdir}/*"
            rm -fr ${tmpdir}/*
            echo "PROGRESS : cleaning finished at :"
            date

# TODO :
# cotter_wsclean.config
# phase center
# tile flagging (flag in metafits)
# removing CASA ms
# using /tmp or RAMDISK on garrawarla / Topaz 


#            if [[ -d ${obsid}_${timestamp}.ms ]]; then   
#               date   
#               echo "flagdata('${obsid}_${timestamp}.ms',mode='unflag')" > unflag.py
#
#              if [[ -s ../flagged_tiles.txt ]]; then
#                 echo "rm -f flag_files.py"
#                 rm -f flag_files.py
#                 
#                 echo > flag_files.py
#                 
#                 for tile in `cat ../flagged_tiles.txt`
#                 do
#                    echo "flagdata(vis='${obsid}_${timestamp}.ms',antenna='${tile}')" >> flag_files.py                    
#                 done
#                 
#                 echo "casapy --nologger -c flag_files.py"
#                 casapy --nologger -c flag_files.py
#              fi 
#      
#              date   
#              if [[ -s ${cal} && ${use_casa_cal} -gt 0 ]]; then
#                  echo "casapy --nologger -c $SMART_DIR/bin/apply_custom_cal.py ${obsid}_${timestamp}.ms ${cal}"
#                  casapy --nologger -c $SMART_DIR/bin/apply_custom_cal.py ${obsid}_${timestamp}.ms ${cal}
#              else
#                   echo "WARNING : apply solutions is now performed in cotter - using option -full-apply ${bin_file}"
#              fi
#      
#              if [[ $do_remove -gt 0 || $do_remove_gpufits -gt 0 ]]; then
#                  echo "rm -fr ${obsid}_${timestamp}*.fits"
#                  rm -fr ${obsid}_${timestamp}*.fits
#              else
#                  echo "WARNING : remove is not required (may produce a lot of data) !"
#              fi
#           else
#              echo "ERROR : CASA measurements set ${obsid}_${timestamp}.ms not created -> Exiting the script !"
#              exit;
#           fi           

#           if [[ -s ../${peel_model_file} ]]; then
#              echo "INFO : using ../${peel_model_file} to peel sources"
#           
#              echo "cp ../${peel_model_file} ."
#              cp ../${peel_model_file} .
#           
#              mkdir mwapy/
#              ln -sf ../../data mwapy/
#           else
#              echo "WARNING : file ../${peel_model_file} does not exist -> no peeling required"
#           fi

#            # OLD script : wsclean_auto.sh 
#            ux_start=`date +%s`
#            if [[ "$wsclean_type" == "standard" || "$wsclean_type" == "deep_clean" ]]; then
#               echo "$SMART_DIR/bin/wsclean_auto_optimised.sh ${obsid}_${timestamp}.ms $n_iter 0 ${beam_corr_type} ${imagesize} ${wsclean_pbcorr} ${wsclean_type} ${wsclean_options}" 
#               $SMART_DIR/bin/wsclean_auto_optimised.sh ${obsid}_${timestamp}.ms $n_iter 0 ${beam_corr_type} ${imagesize} ${wsclean_pbcorr} ${wsclean_type} ${wsclean_options}
#            else
#                  if [[ "$wsclean_type" == "jay" || "$wsclean_type" == "jay8096" ]]; then
#                     if [[ "$wsclean_type" == "jay" ]]; then
#                        echo "time $SMART_DIR/bin/wsclean_auto_jay.sh ${obsid}_${first_timestamp}.ms $n_iter 0 ${beam_corr_type} ${imagesize} ${wsclean_pbcorr}"
#                        time $SMART_DIR/bin/wsclean_auto_jay.sh ${obsid}_${first_timestamp}.ms $n_iter 0 ${beam_corr_type} ${imagesize} ${wsclean_pbcorr}
#                     fi
#                  else 
#                     echo "ERROR : wsclean_type = $wsclean_type unknown"
#                  fi
#            fi
#            ux_end=`date +%s`
#            ux_diff=$(($ux_end-$ux_start))
#            echo "WSCLEAN_TOTAL : ux_start = $ux_start , ux_end = $ux_end -> ux_diff = $ux_diff" >> benchmarking.txt
         else
            echo "WARNING : CASA ms already exists -> skipped"
         fi   
      else
         echo "Image $wsclean_fits_file already exists -> skipped"
      fi

      if [[ $do_remove -gt 0 ]]; then
         echo "rm -fr ${obsid}_${timestamp}.ms ${obsid}_${timestamp}.ms.flag*"
         rm -fr ${obsid}_${timestamp}.ms ${obsid}_${timestamp}.ms.flag*   
      fi
   fi   
   touch ${wsclean_fits_file}
   
   if [[ $subdirs -gt 0 ]]; then
      cd $original_dir
   fi
done


if [[ $is_last -gt 0 ]]; then
   if [[ $is_idg -gt 0 ]]; then
      echo "sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_avg_images.sh \"??????????????\" \"-I-image\""
      sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_avg_images.sh "??????????????" "-I-image" 
   else
      echo "sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_avg_images.sh"
      sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_avg_images.sh   
   fi
fi

