#!/bin/bash

for stokes in `echo "I Q U V"`
do
   ls wsclean*-image_${stokes}.fits > fits_stokes_${stokes}
   
   
   echo "avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits"
   avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits 
done

miriad_add_squared.sh mean_stokes_Q.fits mean_stokes_U.fits mean_stokes_L.fits
