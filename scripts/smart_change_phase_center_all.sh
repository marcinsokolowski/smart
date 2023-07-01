#!/bin/bash

for casa_ms in `ls -d *.ms`
do
   echo "/home/msok/mwa_software/anoko/anoko/chgcentre/build/chgcentre ${casa_ms} 00h34m08.9s -07d21m53.409s"
   /home/msok/mwa_software/anoko/anoko/chgcentre/build/chgcentre ${casa_ms} 00h34m08.9s -07d21m53.409s
done
