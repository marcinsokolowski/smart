#!/bin/bash

source_dir=../
if [[ -n "$1" && "$1" != "-" ]]; then
   source_dir=$1
fi

ln -s ${source_dir}/data
cp ${source_dir}/*.metafits .
cp ${source_dir}/timestamps*txt .
cp ${source_dir}/*.bin .
cp ${source_dir}/flagged*.txt .

cp ${source_dir}/doit! .
cp ${source_dir}/*! .
cp ${source_dir}/*.sh .

cp ${source_dir}/peel_model.txt .
