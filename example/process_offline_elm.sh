#!/usr/bin/env bash


export HDF5_USE_FILE_LOCKING=FALSE
module load nco


#CNP
CaseIDs=(e3sm_ppe_baseline_hcru_hcru_newSF_20TR e3sm_ppe_baseline_hcru_hcru_20TR)

#           e3sm_ppe_baseline_hcru_hcru_newSF_20TR \

TopDir=/global/cfs/cdirs/m3937/minxu/E3SM_PPE/baseline/run_root/
OutDir=/global/cfs/cdirs/m3937/minxu/E3SM_PPE/baseline/processed/

YearAlign=0
YearRange=1901-2008




for cid in "${CaseIDs[@]}"; do
    srun -N 1 ./elm_singlevar_ts.bash --caseid $cid -y $YearRange -a $YearAlign \
          -i $TopDir/$cid/run \
          -o $OutDir \
          -e ${ExpNms[$i]} -m e3sm_elm \
          --ncclimo --ilamb &
          #-g $DstGrd --no-gen-ts --ncremap --prepcmor &
    i=$((i+1))
    echo $i
done

wait

