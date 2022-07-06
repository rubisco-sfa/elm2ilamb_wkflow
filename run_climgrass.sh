#!/usr/bin/bash

CaseNames=(\
           ClimGrass_C0T1D0_AT-CGr_I20TRCNPRDCTCBC \
           ClimGrass_C1T0D0_AT-CGr_I20TRCNPRDCTCBC \
           ClimGrass_C1T1D0_AT-CGr_I20TRCNPRDCTCBC \
           ClimGrass_C1T2D0_AT-CGr_I20TRCNPRDCTCBC \
           ClimGrass_C2T1D0_AT-CGr_I20TRCNPRDCTCBC \
           ClimGrass_C2T2D0_AT-CGr_I20TRCNPRDCTCBC \
           ClimGrass_C2T2D1_AT-CGr_I20TRCNPRDCTCBC)

for cname in "${CaseNames[@]}"; do
    echo x${cname}x
    ./elm_singlevar_ts.bash -c $cname -y 1901-2020 -a 0 -i /compyfs/yang954/e3sm_scratch/$cname/run/ -o /compyfs/minxu/scratch/forxj/ClimGrass/ \
               -e ClimGrass -m e3sm --ncclimo --prepcmor --hfs
done


# ./elm_singlevar_ts.bash -c ClimGrass_C0T2D0_AT-CGr_I20TRCNPRDCTCBC -y 1901-2020 -a 0 -i /compyfs/yang954/e3sm_scratch/ClimGrass_C0T2D0_AT-CGr_I20TRCNPRDCTCBC/run/ -o /compyfs/minxu/scratch/forxj/ClimGrass/ -e ClimGrass -m e3sm --ncclimo --prepcmor --hfs
