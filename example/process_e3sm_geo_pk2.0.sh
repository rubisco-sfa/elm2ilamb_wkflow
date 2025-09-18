#!/usr/bin/env bash


E3SM_SimuDir="/ccs/home/mxu/E3SM_simulations/"
E3SM_PostDir="/lustre/storm/nwp501/scratch/mxu/share_miller_andes/E3SM_GEO_PP_temp"

#CaseNames=(20220528.PkShav1.5_GEOENG_SSP534OS_RUBISCO_NEWSFLU_CNPCTCSSP_OIBGC.ne30_oECv3.miller)
CaseNames=(\
	   20220418.GEOENG_HIST_RUBISCO_NEWSFLU_CNPCTC20TR_OIBGC.ne30_oECv3.miller \
	   20220522.GEOENG_SSP534OS_RUBISCO_NEWSFLU_CNPCTCSSP_OIBGC.ne30_oECv3.miller)


#ExpNms=('Geo-1.5-SSP534OS' 'Geo-HIST' 'Geo-SSP534OS')
ExpNms=('Geo-HIST' 'Geo-SSP534OS')

SrcGrd=/lustre/storm/nwp501/scratch/mxu/grids/SCRIPgrid_ne30np4_nomask_c101123.nc
DstGrd=/lustre/storm/nwp501/scratch/mxu/grids/cmip6_180x360_scrip.20181001.nc


i=0


YearAlign=0

# & cause the ncremap detects the pipeline failed
for case in "${CaseNames[@]}"; do

    if [[ $case == *"HIST"* ]]; then
	YearRange=1850-2015
    else
	YearRange=2040-2100
    fi



    srun -N 1 ./elm_singlevar_ts.bash --caseid $case -y $YearRange -a $YearAlign \
    #./elm_singlevar_ts.bash --caseid $case -y $YearRange -a $YearAlign \
          -i $E3SM_SimuDir/$case/run \
          -o $E3SM_PostDir \
          -e ${ExpNms[$i]} -m e3sm \
          -s $SrcGrd \
          -g $DstGrd --ncclimo --ncremap --prepcmor &
          #-g $DstGrd --no-gen-ts --ncremap --prepcmor &
    i=$((i+1))
    echo $i
done

wait


