#!/bin/bash -l

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 

#SBATCH --account=pawsey0348
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=16gb
#SBATCH --output=/astro/mwaops/msok/log/smart/smart_avgimages.o%j
#SBATCH --error=/astro/mwaops/msok/log/smart/smart_avgimages.e%j
#SBATCH --export=NONE
source /home/msok/smart/bin/magnus/env

ls ??????????????/wsclean*-image_I.fits > fits_stokes_I
n_seconds=`cat fits_stokes_I | wc -l | awk '{printf("%05d",$1);}'`
mkdir -p ${n_seconds}_seconds/

for stokes in `echo "I Q U V"`
do
   #  20160617221541
   ls ??????????????/wsclean*-image_${stokes}.fits > fits_stokes_${stokes}
         
            
   echo "time /home/msok/mwa_soft/avg_images/avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits -r 5 -c 100"
   time /home/msok/mwa_soft/avg_images/avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits -r 5 -c 100
                     
   cp mean_stokes_${stokes}.fits ${n_seconds}_seconds/
   cp rms_stokes_${stokes}.fits ${n_seconds}_seconds/
done
                              
miriad_add_squared.sh mean_stokes_Q.fits mean_stokes_U.fits mean_stokes_L.fits                             
cp mean_stokes_L.fits ${n_seconds}_seconds/
                              