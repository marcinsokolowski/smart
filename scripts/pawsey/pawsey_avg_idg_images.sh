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

force=0
if [[ -n "$7" && "$7" != "-" ]]; then
   force=$7
fi
# WARNING : this should realy be later in the code, but need it here to be used in the ls in the next line:

start_second=0
if [[ -n "$8" && "$8" != "-" ]]; then
   start_second=$8
fi

end_second=10000000
if [[ -n "$9" && "$9" != "-" ]]; then
   end_second=$9
fi


ls 20????????????/*-I-image.fits > fits_stokes_I
ls 20????????????/*-Q-image.fits > fits_stokes_Q
ls 20????????????/*-U-image.fits > fits_stokes_U
ls 20????????????/*-V-image.fits > fits_stokes_V


echo "sbatch -p workq -M $sbatch_cluster ~/smart/bin/pawsey/pawsey_avg_images.sh $1 $2 $3 $4 $5 $6 $7 $8 $9"
sbatch -p workq -M $sbatch_cluster ~/smart/bin/pawsey/pawsey_avg_images.sh $1 $2 $3 $4 $5 $6 $7 $8 $9
