#!/bin/bash

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


do_scp=1
if [[ -n "$1" && "$1" != "-" ]]; then
   do_scp=$1
fi
galaxy_path=/astro/mwaops/vcs/1150234552/vis

do_remove=0
if [[ -n "$2" && "$2" != "-" ]]; then
   do_remove=$2
fi

n_timesteps=120
if [[ -n "$3" && "$3" != "-" ]]; then
   n_timesteps=$3
fi

max_ms_count=-1
if [[ -n "$4" && "$4" != "-" ]]; then
   max_ms_count=$4
fi

change_phase_center=1
if [[ -n "$5" && "$5" != "-" ]]; then
   change_phase_center=$5
fi


# object="00h34m08.9s -07d21m53.409s" # J0034 
object="00h36m08.95s -10d34m00.3s" # J0036

imagesize=2048

beam_corr_type=image

awk -v n=${n_timesteps} '{if(((NR-1)%n)==0){print $1}}' timestamps.txt > timestamps_n${n_timesteps}.txt


cp $SMART_DIR/bin/image_tile_auto.py .
cp $SMART_DIR/bin/apply_custom_cal.py .


obsid=1150234552
cal=1150234232.cal

ms_count=0
for start_timestamp in `cat timestamps_n${n_timesteps}.txt`
do
   echo
   date
   
   casa_ms=${obsid}_${start_timestamp}.ms
   
   if [[ ! -d ${casa_ms} ]]; then
      if [[ $do_scp -gt 0 ]]; then 
         awk -v n_timesteps=${n_timesteps} -v start_timestamp=${start_timestamp} -v count=0 -v started=0 '{if($1==start_timestamp){started=1;}if(started>0 && count<n_timesteps){print $1;count+=1;}}' timestamps.txt > ${start_timestamp}_timesteps.txt
         check=`cat ${start_timestamp}_timesteps.txt | wc -l`
         echo "check = $check"          

         gpu_list=""      
         index=0
         for timestamp in `cat ${start_timestamp}_timesteps.txt`
         do
            index_str=`echo $index | awk '{printf("%02d",$1);}'`
            
            echo
            date
            echo "getting timestamp = $timestamp , index_str = $index_str"
            echo "rsync -avP galaxy:${galaxy_path}/${obsid}_${timestamp}*.fits ."
            rsync -avP galaxy:${galaxy_path}/${obsid}_${timestamp}*.fits .
            
            if [[ $index -gt 0 ]]; then
               # 1150234552_20160617213543_gpubox22_00.fits
               file_template=`ls ${obsid}_${timestamp}_gpubox??_00.fits`

               for file00 in `ls $file_template`               
               do
                  file_index=${file00%%_00.fits}_${index_str}.fits
               
                  echo "mv ${file00} ${file_index}"
                  mv ${file00} ${file_index}
               done
            else
               echo "WARNING : index = $index -> file ${obsid}_${timestamp}_00.fits last as is"
            fi           
            
            gpu_list=$gpu_list" "${obsid}_${timestamp}*gpubox*.fits
            index=$(($index+1))
         done
      fi

      # prepapre metafits :
      # echo "getmeta! ${obsid}"
      # getmeta! ${obsid}
#      echo "cp ${obsid}.metafits ${start_timestamp}.metafits"
#      cp ${obsid}.metafits ${start_timestamp}.metafits
      
      # prepare !
#      path=`which fix_metafits_time_radec.py`
#      echo "python $path ${start_timestamp}.metafits"
#      python $path ${start_timestamp}.metafits
               
      echo "cotter -absmem 64 -j 12 -timeres 4 -freqres 0.01 -noflagautos  -m ${start_timestamp}.metafits -norfi -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -o ${casa_ms} ${gpu_list}"
      cotter -absmem 64 -j 12 -timeres 4 -freqres 0.01 -noflagautos  -m ${start_timestamp}.metafits -norfi -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -o ${casa_ms} ${gpu_list}  
  
#      date   
#      echo "flagdata('${casa_ms}',mode='unflag')" > unflag.py
#      echo "casapy -c unflag.py"
#      casapy -c unflag.py 
      
      date   
      echo "casapy -c apply_custom_cal.py ${casa_ms} ${cal}"
      casapy -c apply_custom_cal.py ${casa_ms} ${cal}
      
      if [[ $do_remove -gt 0 ]]; then
         echo "rm -fr ${gpu_list}"
         rm -fr ${gpu_list}
      else
         echo "WARNING : remove is not required (may produce a lot of data) !"
      fi
   else
      echo "WARNING : CASA ms already exists -> skipped"
   fi

   if [[ $change_phase_center -gt 0 ]]; then
      date
      echo "/home/msok/mwa_software/anoko/anoko/chgcentre/build/chgcentre ${casa_ms} ${object}"
      /home/msok/mwa_software/anoko/anoko/chgcentre/build/chgcentre ${casa_ms} ${object}
      date
   fi
   
   echo "$SMART_DIR/bin/wsclean_auto.sh ${casa_ms} - 0 ${beam_corr_type} ${imagesize}"
   $SMART_DIR/bin/wsclean_auto.sh ${casa_ms} - 0 ${beam_corr_type} ${imagesize}
         
   date
   echo "casapy -c image_tile_auto.py --imagesize=2048 ${casa_ms}"
   casapy -c image_tile_auto.py --imagesize=2048 ${casa_ms} 
   
   
   
   
   ms_count=$(($ms_count+1))
   
   if [[ $max_ms_count -gt 0 ]]; then
      if [[ $ms_count -ge $max_ms_count ]]; then
         echo "Requested number of CASA measurements sets reached ( = $max_ms_count ) -> exiting now"
         exit;
      else
         echo "INFO : ms_count = $ms_count < $max_ms_count -> continuing processing ..."
      fi
   else
      echo "INFO : max_ms_count = $max_ms_count -> continuing processing (<0 -> process all timestamps ) ..."
   fi         
done





