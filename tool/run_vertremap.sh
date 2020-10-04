#!/usr/bin/env bash


export PATH=$PATH:/global/homes/z/zender/bin_cori/

drc_rgr=/global/homes/m/minxu/scratch/data/20191123.CO21PCTBGC_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/rgr/atm
hybfile=/global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/e3sm_hybrid_sigma.nc
stdpres=/global/cfs/cdirs/m3522/1pctco2_temp/processed/src/elm2ilamb_wkflow/grids/vrt_prs_cmor_plev19.nc

vertvar="n2ovmr"

module unload nco
which ncremap

function ncdmnsz { ncks --trd -m -M ${2} | grep -E -i ": ${1}, size =" | cut -f 7 -d ' ' | uniq ; }

varlist=(${vertvar})

cd $drc_rgr

export OMP_PROC_BIND=false

#/bin/rm -f tmp_vert.nc
for vr in "${varlist[@]}"; do
    ncks -h -A $hybfile tmp_vert_000101_015012.nc 
    ncks -h -A PS_000101_015012.nc tmp_vert_000101_015012.nc
    #ncks -h -A ${vr}_000101_015012.nc tmp_vert.nc

    exit;
    which ncremap
    set -x 
    #ncremap --vrt_fl=$stdpres -i tmp_vert.nc -o ${vr}_plev19_000101_015012.nc
   
    # by product


    drc_tmp="./"
    ntimes=`ncdmnsz time tmp_vert.nc`

    if [[ $ntimes -gt 10 ]]; then
        nsects=$((ntimes/10+1))
    else
        nsects=1
    fi

    totjob=-1

    for k in `seq 0 2`; do
        for prc in `seq $k 3 9 `; do
            ib=$((prc*nsects))
            ie=$((prc*nsects+nsects-1))


            if [[ $ib -gt $((ntimes-1)) ]]; then
               break
            else
               totjob=$((totjob+1))
               if [[ $ie -gt $((ntimes-1)) ]]; then
                  ie=$((ntimes-1))
               fi
               echo $prc $lf $ntimes $nsects $ib $ie $totjob
               ncks -O -h -d time,$ib,$ie,1 tmp_vert.nc ${drc_tmp}/tmp$prc.nc && \
               ncap2 -O -h -s 'PFULL[time,lat,lon,lev]=hybm*PS+hyam*P0' tmp$prc.nc -o tmp$prc.rlt1.nc && \
               ncap2 -O -h -s 'PHALF[time,lat,lon,ilev]=hybi*PS+hyai*P0' tmp$prc.nc -o tmp$prc.rlt2.nc &
               prc_pid+=($!)
               echo $prc_pid
            fi
        done

        for pid in "${prc_pid[@]}"; do
            wait $pid
        done
    done


    ncrcat -O -h tmp?.rlt1.nc -o PFULL_000101_015012.nc
    ncrcat -O -h tmp?.rlt2.nc -o PHALF_000101_015012.nc
    #ncap2 -h -s 'PHALF[time,lat,lon,ilev]=hybi*PS+hyai*100000.' tmp_vert.nc -o PHALF_000101_015012.nc
done



