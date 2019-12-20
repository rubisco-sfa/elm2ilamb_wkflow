#!/usr/bin/env bash 


../elm_singlevar_ts.bash -c 20190308.BDRD_CNPECACNT_20TR.ne30_oECv3.edison  -y 2000-2006 -a 0 \
-s /global/homes/m/minxu/scratch/tmp/SCRIPgrid_ne30np4_nomask_c101123.nc \
-g /global/homes/m/minxu/scratch/tmp/180x360_SCRIP.20150901.nc \
-o /global/cscratch1/sd/minxu/ILAMB_WCYCLE_20190319/cbgc_data/ECA_demo/ -m E3SM-ECA -e CBGCv1 \
-i /project/projectdirs/acme/xyk/CBGC_outputs/ECA/BDRD/ --addfxflds  --ilamb --ncclimo --ncremap --cmip


