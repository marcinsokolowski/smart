#!/bin/bash -l

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 

#SBATCH --account=pawsey0348
#SBATCH --time=04:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=16gb
#SBATCH --output=./smart_avglist.o%j
#SBATCH --error=./smart_avglist.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/magnus/env


timestamps_list=avg_list
if [[ -n "$1" && "$1" != "-" ]]; then
   timestamps_list=$1
fi
# wsclean_1194350120_20171110115805_briggs-I-image.fits
# ls ??????????????/wsclean*_briggs-image_I.fits > fits_stokes_I
# n_seconds=`cat fits_stokes_I | wc -l | awk '{printf("%05d",$1);}'`

# outdir=${n_seconds}_seconds
outdir=""
if [[ -n "$2" && "$2" != "-" ]]; then
   outdir="$2"
fi

max_rms=0.5 # maximum allowed rms on 1-second images, based on distributions see memo : 20200626_imaging_of_extended_1276725752_20200620_pre-sunrise.odt
if [[ -n "$3" && "$3" != "-" ]]; then
   max_rms=$3
fi

if [[ ! -n "${outdir}" ]]; then
   outdir=${timestamps_list}_seconds_maxrms${max_rms}
fi

rms_radius=10
if [[ -n "$4" && "$4" != "-" ]]; then
   rms_radius=$4
fi

rms_center="(1050,990)"
if [[ -n "$5" && "$5" != "-" ]]; then
   rms_center=$5
fi


mkdir -p ${outdir}

for stokes in `echo "I Q U V"`
do
   #  20160617221541
   rm -f ${timestamps_list}_fits_stokes_${stokes}
   for timestep in `cat ${timestamps_list}`
   do   
      ls ${timestep}/wsclean*_briggs-image_${stokes}.fits >> ${timestamps_list}_fits_stokes_${stokes}
   done
   
   echo "Averaging list of files:"
   cat  ${timestamps_list}_fits_stokes_${pol}
         
# old with some rediculosuly large window :            
#   echo "time $SMART_DIR/bin/avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits -r 10 -w \"(1200,700)-(1900,900)\""
#   time $SMART_DIR/bin/avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits -r 10 -w "(1200,700)-(1900,900)"

   echo "time $SMART_DIR/bin/avg_images ${timestamps_list}_fits_stokes_${stokes} ${outdir}/mean_stokes_${stokes}.fits ${outdir}/rms_stokes_${stokes}.fits -r ${max_rms} -C \"${rms_center}\" -c ${rms_radius} > ${outdir}/avg_${stokes}.out 2>&1"
   time $SMART_DIR/bin/avg_images ${timestamps_list}_fits_stokes_${stokes} ${outdir}/mean_stokes_${stokes}.fits ${outdir}/rms_stokes_${stokes}.fits -r ${max_rms} -C "${rms_center}" -c ${rms_radius} > ${outdir}/avg_${stokes}.out 2>&1                     
done
                              
miriad_add_squared.sh mean_stokes_Q.fits mean_stokes_U.fits ${outdir}/mean_stokes_L.fits                             

for pol in `echo "XX YY"`                              
do
   rm -f ${timestamps_list}_fits_stokes_${stokes}
   for timestep in `cat ${timestamps_list}`
   do   
      ls ${timestep}/wsclean*_briggs-${pol}-image.fits >> ${timestamps_list}_fits_stokes_${pol}
   done
   
   echo "Averaging list of files:"
   cat  ${timestamps_list}_fits_stokes_${pol}

   echo "time $SMART_DIR/bin/avg_images ${timestamps_list}_fits_stokes_${pol} ${outdir}/mean_stokes_${pol}.fits ${outdir}/rms_stokes_${pol}.fits -r ${max_rms} -C \"${rms_center}\" -c ${rms_radius} > ${outdir}/avg_${pol}.out 2>&1"
   time $SMART_DIR/bin/avg_images ${timestamps_list}_fits_stokes_${pol} ${outdir}/mean_stokes_${pol}.fits ${outdir}/rms_stokes_${pol}.fits -r ${max_rms} -C "${rms_center}" -c ${rms_radius} > ${outdir}/avg_${pol}.out 2>&1                     
done
