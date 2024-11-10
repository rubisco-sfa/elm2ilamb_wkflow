#!/usr/bin/env bash


export HDF5_USE_FILE_LOCKING=FALSE

CaseNames=(\
            2024-10-31.trans_EXPAI_RUBISCO_CMIP6_phase3_co2plus400.I20TRCNPRDCTCBC.hcru_hcru.pm-cpu.intel_001 )
            #-2024-10-28.trans_EXPAI_RUBISCO_CMIP6_phase3.I20TRCNPRDCTCBC.hcru_hcru.pm-cpu.intel_001 \
            #-2024-10-29.trans_EXPAI_RUBISCO_CMIP6_phase3_co2plus100.I20TRCNPRDCTCBC.hcru_hcru.pm-cpu.intel_001 \
            #-2024-10-29.trans_EXPAI_RUBISCO_CMIP6_phase3_co2plus200.I20TRCNPRDCTCBC.hcru_hcru.pm-cpu.intel_001 \
            #-2024-10-31.trans_EXPAI_RUBISCO_CMIP6_phase3_co2plus400.I20TRCNPRDCTCBC.hcru_hcru.pm-cpu.intel_001 )

OutDir=/pscratch/sd/m/minxu/E3SM_simulations/
CmrDir=/pscratch/sd/m/minxu/E3SM_postprocess/

Script=`readlink -f $0`
SrcDir=`dirname $Script`


for ni in `seq 1 36`; do

    cinst=`printf "%04d" $ni`

    echo "processing $cinst"
    for cname in "${CaseNames[@]}"; do
        echo x${cname}x
        echo $OutDir/$cname/run/
        $SrcDir/../elm_singlevar_ts.bash -c $cname -y 1991-2014 -a 0 -i $OutDir/$cname/run/ -o $CmrDir \
                   -e expai_001 -m e3sm --ncclimo --ensemble ${cinst} --tabname lmon
    done


done

# get fix data
./elm_singlevar_ts.bash -c $cname -y 1991-2014 -a 0 -i $OutDir/$cname/run/ -o $CmrDir \
               -e expai_001 -m e3sm --ncclimo --ensemble ${cinst} --prepcmor --addfxflds --linkfil

