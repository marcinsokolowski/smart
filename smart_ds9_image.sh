#!/bin/bash

fits=mean_stokes_I.fits
if [[ -n "$1" && "$1" != "-" ]]; then
   fits=$1
fi

postfix=".fits"
if [[ -n "$2" && "$2" != "-" ]]; then
   postfix=$2
fi

options=""
if [[ -n "$3" && "$3" != "-" ]]; then
   options=$3
fi

quit=1
quit_options=" -quit"
if [[ -n "$4" && "$4" != "-" ]]; then
   quit=0
fi
if [[ $quit -le 0 ]]; then
   quit_options=""
fi


scale_mode="-scale mode 99.5"
auto_options=""
b_fits=${fits%%.fits}
type=`echo $fits | awk -F "_" '{print $1;}'`
stokes=`echo $b_fits | awk -F "_" '{l=length($1);print $3;}'`
if [[ $type == "rms" && $stokes != "I" ]]; then # $stokes == "L" && $type == "mean"
   auto_options="-cmap value 5.0364963 0.0875912"
fi   

if [[ $stokes == "L" && $type == "mean" ]]; then
   scale_mode=""
fi

mkdir -p images/FINAL/

png=${fits%%fits}png

x_size=`fitshdr $fits | grep NAXIS1 | awk '{print $3}'`

x_size_half=`echo $x_size | awk '{print $1/2;}'`

echo "####################################################################"
echo "PARAMETERS :"
echo "####################################################################"
echo "fits         = $fits -> type = $type , stokes = $stokes"
echo "auto_options = $auto_options"
echo "scale_mode   = $scale_mode"
echo "quit         = $quit ( quit_options = $quit_options )"
echo "####################################################################"


echo "circle $x_size_half $x_size_half 10" > center.reg

ds9 ${fits} -geometry 2000x1200 -scale zscale ${scale_mode} ${auto_options} -zoom 4 -pan 0 0  -view buttons no -view panner no -view magnifier no -view info no \
-grid yes -grid type publication -grid labels def1 no  -grid labels fontsize 30 -grid numerics fontsize 30  -grid grid no  -grid numerics color black  -grid axes type exterior -grid numerics type exterior -grid axes color blue \
-grid tickmarks color blue -grid tickmarks no -grid border no \
-grid numerics gap1 0.5 -grid numerics gap2 -0.5 \
-grid labels gap1 -5.5 -grid labels gap2 8 \
-colorbar yes -colorbar orientation horizontal -colorbar  fontsize 30 ${options} -regions load center.reg -saveimage images/FINAL/${png} ${quit_options}

