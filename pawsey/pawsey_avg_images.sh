#!/bin/bash -l

#  sbatch -p workq -M $sbatch_cluster pawsey_avg_images.sh

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
#SBATCH --output=./smart_avgimages.o%j
#SBATCH --error=./smart_avgimages.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env

# WARNING : this should realy be later in the code, but need it here to be used in the ls in the next line:
subdir="??????????????"
if [[ -n "$5" && "$5" != "-" ]]; then
   subdir="$5"
fi

postfix="-image_I"
if [[ -n "$6" && "$6" != "-" ]]; then
   postfix="$6"
fi

# wsclean_1194350120_20171110115805_briggs-I-image.fits
if [[ $postfix == "I-image-pb" ]]; then
   echo "ls ${subdir}/wsclean*_briggs-I-image-pb.fits > fits_stokes_I"
   ls ${subdir}/wsclean*_briggs-I-image-pb.fits > fits_stokes_I
else
   echo "ls ${subdir}/wsclean*_briggs${postfix}.fits > fits_stokes_I"
   ls ${subdir}/wsclean*_briggs${postfix}.fits > fits_stokes_I
fi   

n_seconds=`cat fits_stokes_I | wc -l | awk '{printf("%05d",$1);}'`

# outdir=${n_seconds}_seconds
outdir=""
if [[ -n "$1" && "$1" != "-" ]]; then
   outdir="$1"
fi

# max_rms=0.5 # maximum allowed rms on 1-second images, based on distributions see memo : 20200626_imaging_of_extended_1276725752_20200620_pre-sunrise.odt
max_rms=10000.00
if [[ -n "$2" && "$2" != "-" ]]; then
   max_rms=$2
fi

if [[ ! -n "${outdir}" ]]; then
   outdir=${n_seconds}_seconds_maxrms${max_rms}
fi

rms_radius=10
if [[ -n "$3" && "$3" != "-" ]]; then
   rms_radius=$3
fi

rms_center="(1050,990)"
if [[ -n "$4" && "$4" != "-" ]]; then
   rms_center=$4
fi

# subdir="??????????????"
# if [[ -n "$5" && "$5" != "-" ]]; then
#   subdir="$5"
# fi

echo "################################"
echo "PARAMETERS:"
echo "################################"
echo "subdir = $subdir"
echo "################################"


mkdir -p ${outdir}

for stokes in `echo "I Q U V"`
do
   #  20160617221541      
   if [[ $postfix == "I-image-pb" ]]; then
      echo "ls ${subdir}/wsclean*_briggs-${stokes}-image-pb.fits > fits_stokes_${stokes}"
      ls ${subdir}/wsclean*_briggs-${stokes}-image-pb.fits > fits_stokes_${stokes}
   else
      echo "ls ${subdir}/wsclean*_briggs-image_${stokes}.fits > fits_stokes_${stokes}"
      ls ${subdir}/wsclean*_briggs-image_${stokes}.fits > fits_stokes_${stokes}
   fi
         
# old with some rediculosuly large window :            
#   echo "time $SMART_DIR/bin/avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits -r 10 -w \"(1200,700)-(1900,900)\""
#   time $SMART_DIR/bin/avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits -r 10 -w "(1200,700)-(1900,900)"

   echo "time $SMART_DIR/bin/avg_images fits_stokes_${stokes} ${outdir}/mean_stokes_${stokes}.fits ${outdir}/rms_stokes_${stokes}.fits -r ${max_rms} -C \"${rms_center}\" -c ${rms_radius} > ${outdir}/avg_${stokes}.out 2>&1"
   time $SMART_DIR/bin/avg_images fits_stokes_${stokes} ${outdir}/mean_stokes_${stokes}.fits ${outdir}/rms_stokes_${stokes}.fits -r ${max_rms} -C "${rms_center}" -c ${rms_radius} > ${outdir}/avg_${stokes}.out 2>&1                     
done
                              
miriad_add_squared.sh mean_stokes_Q.fits mean_stokes_U.fits ${outdir}/mean_stokes_L.fits                             

for pol in `echo "XX YY"`                              
do
   ls ${subdir}/wsclean*_briggs-${pol}-image.fits > fits_stokes_${pol}

   echo "time $SMART_DIR/bin/avg_images fits_stokes_${pol} ${outdir}/mean_stokes_${pol}.fits ${outdir}/rms_stokes_${pol}.fits -r ${max_rms} -C \"${rms_center}\" -c ${rms_radius} > ${outdir}/avg_${pol}.out 2>&1"
   time $SMART_DIR/bin/avg_images fits_stokes_${pol} ${outdir}/mean_stokes_${pol}.fits ${outdir}/rms_stokes_${pol}.fits -r ${max_rms} -C "${rms_center}" -c ${rms_radius} > ${outdir}/avg_${pol}.out 2>&1                     
done

# calculate RMS 
cd ${outdir}
ls *.fits > fits_list
echo "sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_rms_test.sh"
sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_rms_test.sh 
cd -
