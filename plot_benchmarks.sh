#!/bin/bash

grep COTTER_TOTAL benchmarking.txt | awk '{print $13;}' > cotter.txt
grep WSCLEAN benchmarking.txt | awk '{print $13;}' > wsclean.txt
grep BEAM_CORR benchmarking.txt | awk '{print $13;}' > beamcorr.txt

mkdir -p images/
root -b -q "histofile.C(\"cotter.txt\",0,0,0,50,50,1)"
root -b -q "histofile.C(\"wsclean.txt\",0,0,500,8000,50,1)"
root -b -q "histofile.C(\"beamcorr.txt\",0,0,1200,2200,50,1)"

cd images/
gthumb -n *png &




