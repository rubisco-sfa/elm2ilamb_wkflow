#!/usr/bin/env bash


export HDF5_USE_FILE_LOCKING=FALSE
module load nco


E3SM_SimuDir="/global/cfs/projectdirs/m3522/1pctco2_temp"
E3SM_PostDir="/global/cscratch1/sd/minxu/postprocess/"

#CaseNames=(20220102.HIST_RUBISCO_NEWSFLU_CNPCTC20TR_OIBGC.ne30_oECv3.compy)
#CaseNames=(20220610.SSP370_RUBISCO_NEWSFLU_CNPCTCSSP_OIBGC.ne30_oECv3.compy 20220626.SSP534OS_RUBISCO_NEWSFLU_CNPCTC20TR_OIBGC.ne30_oECv3.compy)
CaseNames=(20220626.SSP534OS_RUBISCO_NEWSFLU_CNPCTC20TR_OIBGC.ne30_oECv3.compy)


#ExpNms=('Geo-1.5-SSP534OS' 'Geo-HIST' 'Geo-SSP534OS')
#ExpNms=('RUBISCO-HIST')
#ExpNms=('RUBISCO-SSP370' 'RUBISCO-SSP534OS')
ExpNms=('RUBISCO-SSP534OS')

SrcGrd=/global/u2/m/minxu/MyGit/MySrc/elm2ilamb_wkflow/grids/SCRIPgrid_ne30np4_nomask_c101123.nc
DstGrd=/global/u2/m/minxu/MyGit/MySrc/elm2ilamb_wkflow/grids/cmip6_180x360_scrip.20181001.nc


i=0


YearAlign=0

# & cause the ncremap detects the pipeline failed
for case in "${CaseNames[@]}"; do
    if [[ $case == *"HIST"* ]]; then
        YearRange=1850-2014
    elif [[ $case == *"SSP370"* ]]; then
        YearRange=2015-2100
    else
        YearRange=2040-2100
    fi

    #srun -N 1 ./elm_singlevar_ts.bash --caseid $case -y $YearRange -a $YearAlign \
    ./elm_singlevar_ts.bash --caseid $case -y $YearRange -a $YearAlign \
          -i $E3SM_SimuDir/$case/run \
          -o $E3SM_PostDir \
          -e ${ExpNms[$i]} -m e3sm \
          -s $SrcGrd \
          -g $DstGrd --ncclimo --ncremap --tabname Amon --numcc-remap 3 --addfxflds
          #-g $DstGrd --no-gen-ts --ncremap --prepcmor &
    i=$((i+1))
    echo $i
done

#wait

