#!/usr/bin/env bash


export HDF5_USE_FILE_LOCKING=FALSE

CaseNames=(\
           20240903_TRENDY_f09_S0)

           #20230830_S1_f09_f09_ICB20TRCNPRDCTCBC \
           #20230830_S2_f09_f09_ICB20TRCNPRDCTCBC \
           #20230830_S3_f09_f09_ICB20TRCNPRDCTCBC \
           #20230830_S0_f09_f09_ICB20TRCNPRDCTCBC)

OutDir=/gpfs/wolf2/cades/cli185/scratch/xyk/e3sm_run/
CmrDir=/gpfs/wolf2/cades/cli185/scratch/mfx/foryxj/trendy_postprocess/fv09

Script=`readlink -f $0`
SrcDir=`dirname $Script`


for cname in "${CaseNames[@]}"; do
    echo x${cname}x
    echo $OutDir/$cname/run/
    $SrcDir/../elm_singlevar_ts.bash -c $cname -y 1700-2023 -a 0 -i $OutDir/$cname/run/ -o $CmrDir \
               -e TRENDY2024 -m e3sm --ncclimo --prepcmor 
done

# get fix data
#./elm_singlevar_ts.bash -c $cname -y 1700-2022 -a 0 -i $OutDir/$cname/run/ -o $CmrDir \
#               -e TRENDY -m e3sm --ncclimo --prepcmor --addfxflds --linkfil

