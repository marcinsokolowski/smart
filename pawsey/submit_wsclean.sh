#!/bin/bash -l

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 
# 
# INFO :
#   --tasks-per-node=8 means that so many instances of the program will be running on a single node - NOT THREADS for THREADS use : --cpus-per-node=8
#   #SBATCH --cpus-per-gpu=1

# WARNING : #SBATCH --account= will soon be removed to make it more portable between different supercomputers. 
#           then it will be better to use sbatch --account=??? option to specify which account to use for this

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=128gb
#SBATCH --output=./wsclean.o%j
#SBATCH --error=./wsclean.e%j
#SBATCH --export=NONE

echo "srun time /pawsey/mwa_sles12sp4/apps/cascadelake/gcc/8.3.0/wsclean/2.9/bin/wsclean -name wsclean_1276619416_20200619165246_briggs -j 6 -size 8192 8192  -pol XX,YY,XY,YX -abs-mem 128 -weight briggs -1 -scale 0.0047 -nmiter 1 -niter 10000 -threshold 0.050 -mgain 0.85 -minuv-l 30 -join-polarizations  1276619416_20200619165246.ms"
srun time /pawsey/mwa_sles12sp4/apps/cascadelake/gcc/8.3.0/wsclean/2.9/bin/wsclean -name wsclean_1276619416_20200619165246_briggs -j 6 -size 8192 8192  -pol XX,YY,XY,YX -abs-mem 128 -weight briggs -1 -scale 0.0047 -nmiter 1 -niter 10000 -threshold 0.050 -mgain 0.85 -minuv-l 30 -join-polarizations  1276619416_20200619165246.ms
 