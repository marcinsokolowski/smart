#!/bin/bash

image1=fits1.fits
if [[ -n "$1" && "$1" != "-" ]]; then
   image1=$1
fi

image2=fits2.fits
if [[ -n "$2" && "$2" != "-" ]]; then
   image2=$2
fi

imageI=fitsI.fits
if [[ -n "$3" && "$3" != "-" ]]; then
   imageI=$3
fi

out_image=${image2%%.fits}_L.fits
if [[ -n "$4" && "$4" != "-" ]]; then
   out_image=$4
fi


image1_uv=${image1%%fits}uv
image2_uv=${image2%%fits}uv
imageI_uv=${imageI%%fits}uv
out_image_uv=${out_image%%fits}uv

if [[ ! -d ${image1_uv} ]]; then
   echo "fits op=xyin in=${image1} out=${image1_uv}"
   fits op=xyin in=${image1} out=${image1_uv}
else
   echo "INFO : ${image1_uv} already exists"
fi

if [[ ! -d ${image2_uv} ]]; then
   echo "fits op=xyin in=${image2} out=${image2_uv}"
   fits op=xyin in=${image2} out=${image2_uv}
else
   echo "INFO : ${image2_uv} already exists"
fi   

if [[ ! -d ${imageI_uv} ]]; then
   echo "fits op=xyin in=${imageI} out=${imageI_uv}"
   fits op=xyin in=${imageI} out=${imageI_uv}
else
   echo "INFO : ${imageI_uv} already exists"
fi   

echo "rm -fr ${out_image_uv}"
rm -fr ${out_image_uv}

echo "maths exp=\"sqrt(${image1_uv}*${image1_uv}+$image2_uv*${image2_uv})/${imageI_uv}\" out=${out_image_uv}"
maths exp="sqrt(${image1_uv}*${image1_uv}+$image2_uv*${image2_uv})/${imageI_uv}" out=${out_image_uv}


echo "fits op=xyout in=${out_image_uv} out=${out_image}"
fits op=xyout in=${out_image_uv} out=${out_image}

echo "rm -fr ${out_image_uv}"
rm -fr ${out_image_uv}






