#!/usr/bin/env bash


#suffix=Lmon_e3sm_CNP_r1i1p1_185001_201012
suffix=Lmon_e3sm_CNonly_r1i1p1_185001_201012

cp -f ./CMOR/nbp_${suffix}.nc temp.nc

#ncks -h -A ncclimo_NEE.monthly.185001_201012.nc temp.nc
ncks -h -A ncclimo.NEE.monthly.185001_201012.nc temp.nc

ncap2 -O -h -s "nbp=-NEE/1000." temp.nc temp1.nc

#ncrename -O -h -v nbp,oldnbp ./CMOR/nbp_${suffix}.nc  ./CMOR/oldnbp_${suffix}.nc
/bin/mv -f temp1.nc ./CMOR/nbp_${suffix}.nc

/bin/rm -f temp.nc
