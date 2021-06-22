#!/usr/bin/env bash


export HDF5_USE_FILE_LOCKING=FALSE
module load nco


#CNP
#-CaseIDs=(\
#-           20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy \
#-           20191123.CO21PCTBGC_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy \
#-           20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy \
#-           20191123.CO21PCTRAD_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy)


#-TopDir=/global/cfs/projectdirs/m3522/1pctco2_temp/
#-OutDir=/global/cscratch1/sd/minxu/e3sm_cnp_C4MIP_1pctCO2/

#-YearAlign=1899
#-YearRange=0001-0150

#CN
#-CaseIDs=(\
#-            20200802.CO21PCTFUL_RUBISCO_CNCTC20TR_OIBGC.ne30_oECv3.compy \
#-            20200509.CO21PCTBGC_RUBISCO_CNCTC20TR_OIBGC.ne30_oECv3.compy \
#-            20200509.CO21PCTCTL_RUBISCO_CNCTC1850_OIBGC.ne30_oECv3.compy \
#-            20200622.CO21PCTRAD_RUBISCO_CNCTC20TR_OIBGC.ne30_oECv3.compy)
#-
#-ExpNms=(\
#-        1pctco2ful \
#-        1pctco2bgc \
#-        1pctco2ctl \
#-        1pctco2rad) 

CaseIDs=(20200509.CO21PCTBGC_RUBISCO_CNCTC1850_OIBGC.ne30_oECv3.compy)
ExpNms=(1pctco2bgc)

YearAlign=1975
YearRange=0001-0150

TopDir=/global/cfs/projectdirs/m3522/cmip6/1pctCO2-E3SM/
OutDir=/global/cscratch1/sd/minxu/e3sm_cn_C4MIP_1pctCO2/



#-----------------

SrcGrd=/global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/SCRIPgrid_ne30np4_nomask_c101123.nc
DstGrd=/global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/cmip6_180x360_scrip.20181001.nc


i=0

# & cause the ncremap detects the pipeline failed
for cid in "${CaseIDs[@]}"; do
    srun -N 1 ./elm_singlevar_ts.bash --caseid $cid -y $YearRange -a $YearAlign \
          -i $TopDir/$cid/run \
          -o $OutDir \
          -e ${ExpNms[$i]} -m e3sm \
          -s $SrcGrd \
          -g $DstGrd --ncclimo --ncremap --prepcmor &
    i=$((i+1))
    echo $i
done

wait

#-./elm_singlevar_ts.bash --caseid 20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy -y 0001-0150 -a 1899 \
#--i /global/cfs/projectdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run \
#--o /global/cscratch1/sd/minxu/e3sm_cnp_C4MIP_1pctCO2 \
#--e 1pctco2ful -m e3sm \
#--s /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/SCRIPgrid_ne30np4_nomask_c101123.nc \
#--g /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/cmip6_180x360_scrip.20181001.nc --ncclimo --ncremap --prepcmor
#-

#./elm_singlevar_ts.bash --caseid 20191123.CO21PCTBGC_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy -y 0001-0150 -a 1899 \
#-i /global/cfs/projectdirs/m3522/1pctco2_temp/20191123.CO21PCTBGC_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run \
#-o /global/cscratch1/sd/minxu/data  \
#-e 1pctco2bgc -m e3sm \
#-s /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/SCRIPgrid_ne30np4_nomask_c101123.nc \
#-g /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/cmip6_180x360_scrip.20181001.nc --ncclimo --ncremap  --ilamb


#./elm_singlevar_ts.bash --caseid 20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy -y 0001-0150 -a 1899 \
#-i /global/cfs/projectdirs/m3522/1pctco2_temp/20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy/run \
#-o /global/cscratch1/sd/minxu/data \
#-e 1pctco2ctl -m e3sm \
#-s /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/SCRIPgrid_ne30np4_nomask_c101123.nc \
#-g /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/cmip6_180x360_scrip.20181001.nc --ncclimo  --ncremap --ilamb

#-./elm_singlevar_ts.bash --caseid 20191123.CO21PCTRAD_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy -y 0001-0150 -a 1899 \
#--i /global/cfs/projectdirs/m3522/1pctco2_temp/20191123.CO21PCTRAD_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run \
#--o /global/cscratch1/sd/minxu/data \
#--e 1pctco2bgc -m e3sm \
#--s /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/SCRIPgrid_ne30np4_nomask_c101123.nc \
#--g /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/cmip6_180x360_scrip.20181001.nc --ncclimo  --ncremap --ilamb
