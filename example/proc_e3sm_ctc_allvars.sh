#!/bin/usr/env bash


./clm_singlevar_ts.bash -c 20181217.BDRD_CNPCTC20TR_OIBGC -y 1900-2006 -a 0  \
        -o ../../../ILAMB_WCYCLE_20190319/cbgc_ctc_prc_demo -m E3SM_CTC -e CBGCv1 --addfxflds \
        -i /global/cscratch1/sd/shix/E3SM_simulations/20181217.BDRD_CNPCTC20TR_OIBGC.ne30_oECv3.edison/archive/20181217.BDRD_CNPCTC20TR_OIBGC.ne30_oECv3.edison/lnd/hist/ 
        -s /global/homes/m/minxu/scratch/tmp/SCRIPgrid_ne30np4_nomask_c101123.nc -g /global/homes/m/minxu/scratch/tmp/180x360_SCRIP.20150901.nc --cmip --ilamb --no-gen-ts --ncremap
