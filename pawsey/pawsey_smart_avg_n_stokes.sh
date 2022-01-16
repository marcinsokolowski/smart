#!/bin/bash -l

#  sbatch -p workq -M $sbatch_cluster pawsey_smart_avg_n_stokes.sh

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=120gb
#SBATCH --output=./smart_avgnimages.o%j
#SBATCH --error=./smart_avgnimages.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env

n=120 # `ls *_I.fits |wc -l`
if [[ -n "$1" && "$1" != "-" ]]; then
   n=$1
fi

# IDG : wsclean_1275092416_20200602002456_briggs-I-image.fits -> prefix=wsclean_??????????_20200602??????_briggs- postfix="-image"
prefix="??????????????/wsclean*-image_"
if [[ -n "$2" && "$2" != "-" ]]; then
   prefix=$2
fi

# wsclean*-image_${stokes}.fits
postfix=""
if [[ -n "$3" && "$3" != "-" ]]; then
   postfix=$3
fi

outdir=avg${n}
if [[ -n "$4" && "$4" != "-" ]]; then
   outdir=$4
fi
mkdir -p ${outdir}

beam_fits_file=""
beam_avg_options=""
if [[ -n "${5}" && "${5}" != "-" ]]; then
   beam_fits_file=${5}
   beam_avg_options=" -B $beam_fits_file"   
fi


echo "################################"
echo "PARAMETERS:"
echo "################################"
echo "beam_fits_file = $beam_fits_file (beam_avg_options = $beam_avg_options)"
echo "################################"



tmp_list="tmp_list_avg${n}"

for stokes in `echo "I Q U V"`
do
#   ls wsclean*-image_${stokes}.fits > fits_stokes_${stokes}

# WAS :
#   echo "ls ${prefix}${stokes}${postfix}.fits > fits_stokes_${stokes}"
#   ls ${prefix}${stokes}${postfix}.fits > fits_stokes_${stokes}

   # ok for data in /astro/mwavcs/susmita/1150234552/
   echo "ls ${prefix}${postfix}_${stokes}.fits > fits_stokes_${stokes}"
   ls ${prefix}${postfix}_${stokes}.fits > fits_stokes_${stokes}
   
   index=0
   rm -f ${tmp_list}
   touch ${tmp_list}
   for fits in `cat fits_stokes_${stokes}`
   do
      cnt=`cat ${tmp_list} | wc -l`
      
      if [[ $cnt -lt $n ]]; then
         echo $fits >> ${tmp_list}
         # i=$(($i+1))
      else
         i_str=`echo $index | awk '{printf("%05d",$1);}'`
         
         if [[ -s ${outdir}/mean_stokes_${stokes}_${i_str}.fits && -s ${outdir}/rms_stokes_${stokes}_${i_str}.fits ]]; then
            echo "INFO : files ${outdir}/mean_stokes_${stokes}_${i_str}.fits and ${outdir}/rms_stokes_${stokes}_${i_str}.fits already exist -> skipped, use force=1 to re-process"
         else
            echo "avg_images ${tmp_list} ${outdir}/mean_stokes_${stokes}_${i_str}.fits ${outdir}/rms_stokes_${stokes}_${i_str}.fits -r 1000000000 ${beam_avg_options}"
            avg_images ${tmp_list} ${outdir}/mean_stokes_${stokes}_${i_str}.fits ${outdir}/rms_stokes_${stokes}_${i_str}.fits -r 1000000000 ${beam_avg_options}
         fi

         # add first file to new tmp_list :            
         echo $fits > ${tmp_list}
         
         index=$((index+1))
      fi      
   done

   cd ${outdir}   
   ls mean_stokes_${stokes}_?????.fits > mean_fits_stokes_${stokes}_list
   ls rms_stokes_${stokes}_?????.fits > rms_fits_stokes_${stokes}_list
   
   echo "python $SMART_DIR/bin/dump_pixel_simple.py mean_fits_stokes_${stokes}_list --radius=2 --outfile=mean_fits_stokes_${stokes}.txt --time_step=${n}"
   python $SMART_DIR/bin/dump_pixel_simple.py mean_fits_stokes_${stokes}_list --radius=2 --outfile=mean_fits_stokes_${stokes}.txt --time_step=${n}

   echo "python $SMART_DIR/bin/dump_pixel_simple.py rms_fits_stokes_${stokes}_list --radius=2 --outfile=rms_fits_stokes_${stokes}.txt --time_step=${n}"
   python $SMART_DIR/bin/dump_pixel_simple.py rms_fits_stokes_${stokes}_list --radius=2 --outfile=rms_fits_stokes_${stokes}.txt --time_step=${n}
   
   awk '{if($1!="#"){print $1" "$5;}}' mean_fits_stokes_${stokes}.txt > mean${stokes}.txt
   awk '{if($1!="#"){print $1" "$5;}}' rms_fits_stokes_${stokes}.txt > rms${stokes}.txt

   awk '{if($1!="#"){print $1" "$8;}}' mean_fits_stokes_${stokes}.txt > sum_mean${stokes}.txt
   awk '{if($1!="#"){print $1" "$8;}}' rms_fits_stokes_${stokes}.txt > sum_rms${stokes}.txt

   mkdir -p images/   
   root -q -b -l "plotfile.C(\"mean${stokes}.txt\")"
   root -q -b -l "plotfile.C(\"rms${stokes}.txt\")"
   root -q -b -l "plotfile.C(\"sum_mean${stokes}.txt\")"
   root -q -b -l "plotfile.C(\"sum_rms${stokes}.txt\")"
   cd -
done
