#!/usr/bin/env bash


convert_to_cmip=1

SrcDir=/global/homes/m/minxu/scratch/tmp/test_ncclimo/alm2ilamb_wkflow/

outputpath=/global/homes/m/minxu/scratch/ILAMB_WCYCLE_20190319/hires_prc/
caseid=theta.20180906.branch_noCNT.A_WCYCL1950S_CMIP6_HR

model=e3sm
experiment=hireswcycl
year_range=1982-2011
stryear=1982

if [[ $convert_to_cmip == 1 ]]; then
   /bin/cp -f $SrcDir/clm_to_mip $outputpath/$caseid/rgr
   cd $outputpath/$caseid/rgr
   echo clm_to_mip ${model} ${experiment} ${year_range}

   #renaming
   rename _${stryear} .${stryear} *${stryear}*.nc
   for rgrf in *.nc; do
       /bin/mv $rgrf ${caseid}.$rgrf
   done

   ./clm_to_mip ${model} ${experiment} ${year_range}
fi

