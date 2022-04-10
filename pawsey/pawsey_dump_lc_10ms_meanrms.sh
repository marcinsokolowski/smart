#!/bin/bash

window="(2045,2045)-(2055,2055)" # e.g. "-w (x_start,y_start)-(x_end,y_end)"
if [[ -n "$1" && "$1" != "-" ]]; then
   window="$1"
fi


# XX
pawsey_dump_lc_10ms.sh "(2045,2045)-(2055,2055)" XX - mean_stokes_XX.fits lcmean
pawsey_dump_lc_10ms.sh "(2045,2045)-(2055,2055)" XX - rms_stokes_XX.fits lcrms
                  
# YY
pawsey_dump_lc_10ms.sh "(2045,2045)-(2055,2055)" YY - mean_stokes_YY.fits lcmean
pawsey_dump_lc_10ms.sh "(2045,2045)-(2055,2055)" YY - rms_stokes_YY.fits lcrms
       
# Stokes I                   
pawsey_dump_lc_10ms.sh "(2045,2045)-(2055,2055)" I - mean_stokes_I.fits lcmean
pawsey_dump_lc_10ms.sh "(2045,2045)-(2055,2055)" I - rms_stokes_I.fits lcrms
