#!/usr/bin/env bash

export HDF5_USE_FILE_LOCKING=FALSE

CaseNames=(\
           v3.LR_TSMLT_Historical_LBGC \
	   v3.LR_TSMLT_SSP534OS_LBGC \
	   v3.LR_TSMLT_SSP585_LBGC \
	   v3.LR_TSMLT_SSP585_G6sulfur_LBGC \
	   v3.LR_TSMLT_SSP534OS_G6sulfur_LBGC)

OutDir=/lustre/orion/cli137/world-shared/world-shared/mxu/E3SM_SAI_RAW
CmrDir=/lustre/orion/cli137/world-shared/world-shared/mxu/E3SM_SAI_PROCESSED

Script=`readlink -f $0`
SrcDir=`dirname $Script`



# monthly 2040-2100 or 2020-2100


comp='lnd'


# lnd
for cname in "${CaseNames[@]}"; do
    echo x${cname}x
    echo $OutDir/$cname/run/


    if [[ $cname == *"534"* ]]; then
        year_ranges=("2040-2099")
    elif [[ $cname == *"585"* ]]; then
        year_ranges=("2020-2099")
    elif [[ $cname == *"Hist"* ]]; then
        #year_ranges=("1850-1899" "1900-1949" "1950-2015")
        #year_ranges=("1850-1899" "1900-1949" "1950-2014")
        year_ranges=("1900-1949")
    fi 


    for year_range in "${year_ranges[@]}"; do 

        echo "Processing .. $year_range"

	if [[ $comp == 'lnd' ]]; then
           # lnd
           $SrcDir/../elm_singlevar_ts.bash -c $cname -y $year_range -a 0 \
           	    -i $OutDir/$cname/lnd/hist/ -o $CmrDir \
                   -e e3sm_pk1.5_sai -m e3sm --ncclimo --prepcmor --tabname lmon \
                   --ncremap -s ${SrcDir}/../grids/r05_360x720.nc -g ${SrcDir}/../grids/cmip6_180x360_scrip.20181001.nc
        
        fi 
        #--ncremap --skip-genmap 999

	if [[ $comp == 'atm' ]]; then
           #atm
           $SrcDir/../elm_singlevar_ts.bash -c $cname -y $year_range -a 0 \
                 -i $OutDir/$cname/atm/hist/ -o $CmrDir \
                 -e e3sm_pk1.5_sai -m e3sm --ncclimo --prepcmor --histfile h1 --hfs --tabname all \
                 --ncremap --skip-genmap 888
        fi 

    done 

    # get the fixed file

    if [[ $comp == 'fx' ]]; then
       year_range="1850-2014"
       $SrcDir/../elm_singlevar_ts.bash -c $cname -y $year_range -a 0 \
       	    -i $OutDir/$cname/lnd/hist/ -o $CmrDir \
               -e e3sm_pk1.5_sai -m e3sm --ncclimo --prepcmor --tabname lmon --addfxflds \
               --ncremap -s ${SrcDir}/../grids/r05_360x720.nc -g ${SrcDir}/../grids/cmip6_180x360_scrip.20181001.nc
    fi
done



