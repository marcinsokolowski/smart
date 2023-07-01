#!/bin/bash

calid=1164055336
if [[ -n "$1" && "$1" != "-" ]]; then
   calid="$1"
fi

n_channels=768
if [[ -n "$2" && "$2" != "-" ]]; then
   n_channels=$2
fi

if [[ -s ${calid}.bin ]]; then
   echo "Calibration file ${calid}.bin already exists"
else
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

   echo "unzip -o solutions.zip"
   unzip -o solutions.zip


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

         echo "cp ${bin_file} ${calid}.bin"
         cp ${bin_file} ${calid}.bin
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
fi


echo "python $SMART_DIR/aocal.py ${calid}.bin --final_n_channels=${n_channels} --outfile=${calid}_ch${n_channels}.bin"
python $SMART_DIR/aocal.py ${calid}.bin --final_n_channels=${n_channels} --outfile=${calid}_ch${n_channels}.bin

if [[ -s ${calid}_ch${n_channels}.bin ]]; then
   echo "File ${calid}_ch${n_channels}.bin created"

   echo "cp ${calid}_ch${n_channels}.bin ${calid}.bin"
   cp ${calid}_ch${n_channels}.bin ${calid}.bin
else
   echo "INFORMATION : file ${calid}_ch${n_channels}.bin not created -> already required number of channels ($n_channels)"
fi
