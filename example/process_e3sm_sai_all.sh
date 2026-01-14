#!/usr/bin/env bash

export HDF5_USE_FILE_LOCKING=FALSE


top_dir=/lustre/orion/atm112/world-shared/hgkang/E3SMv3-TSMLT_SAI_exps/

ens_name=H201

ens_dir=archives_${ens_name}

case_names=(\
    archive_v3.LR_TSMLT_Historical_${ens_name} \
    archive_v3.LR_TSMLT_SSP534OS_${ens_name} \
    archive_v3.LR_TSMLT_SSP534OS-SAI_${ens_name} \
    archive_v3.LR_TSMLT_SSP534OS_continue_${ens_name} \
    archive_v3.LR_TSMLT_SSP534OS-SAI_abruptStop_${ens_name} \
    archive_v3.LR_TSMLT_SSP534OS-SAI_continue_${ens_name} \
    archive_v3.LR_TSMLT_SSP585_${ens_name} \
    archive_v3.LR_TSMLT_SSP585-SAI_${ens_name} \
    archive_v3.LR_TSMLT_SSP585_continue_${ens_name} \
    archive_v3.LR_TSMLT_SSP585-SAI_abruptStop_${ens_name} \
    archive_v3.LR_TSMLT_SSP585-SAI_continue_${ens_name} \
)

OutDir=$top_dir
CmrDir=/lustre/orion/cli137/world-shared/mxu/E3SM_SAI_PROCESSED_new


Script=`readlink -f $0`
SrcDir=`dirname $Script`



# monthly 2040-2100 or 2020-2100

# archives_H181/archive_v3.LR_TSMLT_Historical_H181/lnd/hist/


declare -A YearStrt=([Historical]=1850 [SSP534OS]=2040 [SSP534OS-SAI]=2040 [SSP585]=2015 [SSP585-SAI]=2020 [continue]=2100 [abruptStop]=2100)
declare -A YearStop=([Historical]=2014 [SSP534OS]=2099 [SSP534OS-SAI]=2099 [SSP585]=2099 [SSP585-SAI]=2099 [continue]=2149 [abruptStop]=2149)

comp='fx'
#comp='lnd'


# lnd
for cname in "${case_names[@]}"; do

    echo x${cname}x
    echo $OutDir/$ens_dir/$cname/$comp/hist

    #-if [[ "$cname" == *"Historical"* || "$cname" == *"SSP534OS_${ens_name}"* ]]; then
    #-    continue
    #-fi

    if [[  "$cname" == *"Historical"* ]]; then
        echo "process $cname"
    else
        echo "yyyy"
        continue
    fi
    #-if [[  "$cname" == *"SSP585-SAI_continue"* || "$cname" == *"SSP585-SAI_abruptStop"* ]]; then
    #-    echo $cname
    #-else
    #-    continue
    #-fi
    #-if [[  "$cname" == *"SSP585-SAI_${ens_name}"* ]]; then
    #-    echo $cname
    #-else
    #-    continue
    #-fi

    #-if [[ "$cname" != *"SSP534OS_${ens_name}"* ]]; then
    #-   continue
    #-fi

    hist_dir=$OutDir/$ens_dir/$cname/$comp/hist

    for key in "${!YearStrt[@]}"; do
        if [[ "$cname" == *"${key}_${ens_name}"* ]]; then
            year_range=${YearStrt[$key]}-${YearStop[$key]}
            echo ${YearStrt[$key]}, ${YearStop[$key]}
            echo $year_range
        fi 
    done


    if [[ $comp == 'lnd' ]]; then
        # lnd
        $SrcDir/../elm_singlevar_ts.bash -c $cname -y $year_range -a 0 \
            -i $hist_dir -o $CmrDir \
            -e e3sm_sai -m e3sm --ncclimo --prepcmor --tabname lmon \
            --ncremap -s ${SrcDir}/../grids/r05_360x720.nc -g ${SrcDir}/../grids/cmip6_180x360_scrip.20181001.nc
        #-$SrcDir/../elm_singlevar_ts.bash -c $cname -y $year_range -a 0 \
        #-    -i $hist_dir -o $CmrDir \
        #-    -e e3sm_sai -m e3sm --ncclimo --prepcmor --tabname lmon \
        #-    --no-gen-ts --ncremap -s ${SrcDir}/../grids/r05_360x720.nc -g ${SrcDir}/../grids/cmip6_180x360_scrip.20181001.nc
    
    fi 
    #--ncremap --skip-genmap 999
    
    if [[ $comp == 'atm' ]]; then
        #atm
        $SrcDir/../elm_singlevar_ts.bash -c $cname -y $year_range -a 0 \
            -i $hist_dir -o $CmrDir \
            -e e3sm_sai -m e3sm --ncclimo --prepcmor --histfile h1 --hfs --tabname all \
            --ncremap --skip-genmap 888
    fi 

    # get the fixed file
    if [[ $comp == 'fx' ]]; then
        $SrcDir/../elm_singlevar_ts.bash -c $cname -y $year_range -a 0 \
            -i $OutDir/$ens_dir/$cname/lnd/hist -o $CmrDir \
            -e e3sm_sai -m e3sm --ncclimo --prepcmor --tabname lmon --addfxflds \
            --ncremap -s ${SrcDir}/../grids/r05_360x720.nc -g ${SrcDir}/../grids/cmip6_180x360_scrip.20181001.nc
    fi
done
