#!/usr/bin/env bash


export HDF5_USE_FILE_LOCKING=FALSE

CaseNames=(\
           20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.compy)
          #20191123.CO21PCTBGC_RUBISCO_CNPCTC20TR_OIBGC.I1900.compy)

OutDir=/global/homes/m/minxu/scratch/E3SM_1pctCO2/FULL/run
CmrDir=/pscratch/sd/m/minxu/E3SM_1pctCO2/FULL

Script=`readlink -f $0`
SrcDir=`dirname $Script`



for cname in "${CaseNames[@]}"; do
    $SrcDir/../elm_singlevar_ts.bash --caseid $cname -y 0001-0150 -a 1899 \
                 -i $OutDir -o $CmrDir -e 1pctco2bgc -m e3sm --oldname --tabname Aday \
                 -s $SrcDir/../grids/SCRIPgrid_ne30np4_nomask_c101123.nc \
                 -g $SrcDir/../grids/cmip6_180x360_scrip.20181001.nc --hfs --histfile h1 --ncclimo   --ncremap
                #-g $SrcDir/../grids/cmip6_180x360_scrip.20181001.nc --hfs --histfile h1 --no-gen-ts --ncremap

done

