#!/bin/bash

cd ~/

if [[ ! -s smart.tar.gz ]]; then
   echo "File smart.tar.gz not found in the directory ~/ -> please copy smart.tar.gz to your home directory and execute deploy.sh again"
   exit
fi

mkdir -p smart 
cp smart.tar.gz smart/
cd smart/
tar zxvf smart.tar.gz
mv smart bin/

