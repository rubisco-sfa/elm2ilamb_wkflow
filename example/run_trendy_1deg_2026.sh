#!/usr/bin/env bash


export HDF5_USE_FILE_LOCKING=FALSE

CaseNames=(\
           20260820_TRENDY2026_f09_S0 \
           20260820_TRENDY2026_f09_S1 \
           20260820_TRENDY2026_f09_S2 \
           20260820_TRENDY2026_f09_S3 \
           20260820_TRENDY2026_f09_S4 \
           20260820_TRENDY2026_f09_S5 \
           20260820_TRENDY2026_f09_S6 )


OutDir=/scratch/hpcl-cli185/xyk/e3sm_runs/
CmrDir=/scratch/hpcl-cli185/mfx/forxj/trendy_postprocess/fv09

Script=`readlink -f $0`
SrcDir=`dirname $Script`


for cname in "${CaseNames[@]}"; do
    echo x${cname}x
    echo $OutDir/$cname/run/
    $SrcDir/../elm_singlevar_ts.bash -c $cname -y 1700-2025 -a 0 -i $OutDir/$cname/run/ -o $CmrDir \
               -e TRENDY2026 -m e3sm --ncclimo --prepcmor --tabname lmon
done

# get fix data
#-for cname in "${CaseNames[@]}"; do
#-    $SrcDir/../elm_singlevar_ts.bash -c $cname -y 1700-2022 -a 0 -i $OutDir/$cname/run/ -o $CmrDir \
#-               -e TRENDY2026 -m e3sm --ncclimo --prepcmor --addfxflds --linkfil
#-done

