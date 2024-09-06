#!/usr/bin/bash



export HDF5_USE_FILE_LOCKING=FALSE

#-CaseNames=(\
#-           20230926_S0_f09_f09_ICB20TRCNPRDCTCBC \
#-           20230926_S1_f09_f09_ICB20TRCNPRDCTCBC \
#-           20230926_S3_f09_f09_ICB20TRCNPRDCTCBC)

CaseNames=(\
           20230926_S2_f09_f09_ICB20TRCNPRDCTCBC)

           #20230830_S1_f09_f09_ICB20TRCNPRDCTCBC \
           #20230830_S2_f09_f09_ICB20TRCNPRDCTCBC \
           #20230830_S3_f09_f09_ICB20TRCNPRDCTCBC \
           #20230830_S0_f09_f09_ICB20TRCNPRDCTCBC)

OutDir=/compyfs/ricc364/e3sm_scratch/


CmrDir=/qfs/people/xumi699/compyfs/scratch/forxj/trendy_postprocess/new_fv09

for cname in "${CaseNames[@]}"; do
    echo x${cname}x
    echo $OutDir/$cname/run/
    ./elm_singlevar_ts.bash -c $cname -y 1700-2022 -a 0 -i $OutDir/$cname/run/ -o $CmrDir \
               -e TRENDY -m e3sm --ncclimo --prepcmor 
done


# get fix data
#./elm_singlevar_ts.bash -c $cname -y 1700-2022 -a 0 -i $OutDir/$cname/run/ -o $CmrDir \
#               -e TRENDY -m e3sm --ncclimo --prepcmor --addfxflds --linkfil

