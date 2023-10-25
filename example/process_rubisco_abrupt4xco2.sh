#!/usr/bin/env bash


export HDF5_USE_FILE_LOCKING=FALSE
module load nco


E3SM_SimuDir="/global/cfs/projectdirs/m3522/1pctco2_temp"
E3SM_PostDir="/global/cscratch1/sd/minxu/postprocess/"

CaseNames=(20220102.HIST_RUBISCO_NEWSFLU_CNPCTC20TR_OIBGC.ne30_oECv3.compy)
ExpNms=('RUBISCO-HIST')

CaseNames=(20200705.4xCO2FUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy)
ExpNms=(Abrupt4xCO2)


SrcGrd=/global/u2/m/minxu/MyGit/MySrc/elm2ilamb_wkflow/grids/SCRIPgrid_ne30np4_nomask_c101123.nc
DstGrd=/global/u2/m/minxu/MyGit/MySrc/elm2ilamb_wkflow/grids/cmip6_180x360_scrip.20181001.nc

YearAlign=1899
YearRange=0001-0300


i=0

# & cause the ncremap detects the pipeline failed
for case in "${CaseNames[@]}"; do
    #srun -N 1 ./elm_singlevar_ts.bash --caseid $case -y $YearRange -a $YearAlign \
    ./elm_singlevar_ts.bash --caseid $case -y $YearRange -a $YearAlign \
          -i $E3SM_SimuDir/$case/run \
          -o $E3SM_PostDir \
          -e ${ExpNms[$i]} -m e3sm \
          -s $SrcGrd \
          -g $DstGrd --ncclimo --ncremap --prepcmor
    i=$((i+1))
    echo $i
done

#wait

