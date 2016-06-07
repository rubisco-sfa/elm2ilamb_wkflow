#!/bin/bash
CASE=interpfv09_20160308.A_WCYCL2000.ne30_oEC.edison.alpha3_01
MODEL=clm2
HIST=h0
MIYEAR=0001
MFYEAR=0005
#
IYEAR=1970
FYEAR=2010
#
MIN_DAYS=(0.0 31.0 59.0 90.0 120.0 151.0 181.0 212.0 243.0 273.0 304.0 334.0)
MAX_DAYS=(31.0 59.0 90.0 120.0 151.0 181.0 212.0 243.0 273.0 304.0 334.0 365.0)
DAYS=(15.5  45.0  74.5 105.0 135.5 166.0 196.5 227.5 258.0 288.5 319.0 349.5)
#
for ((i=${IYEAR}; i <= ${FYEAR}; )); do
  for ((j=${MIYEAR}; j <= ${MFYEAR}; j++, i++)); do
    MYEAR=`echo ${j} | awk '{printf "%04d\n", $1}'`
    YR=`echo ${i} | awk '{printf "%04d\n", $1}'`
    echo "** Year ${i} **"
    for ((k=1; k <= 12; k++)); do
      MON=`echo ${k} | awk '{printf "%02d\n", $1}'`
      # Change the time units to "days since 1970-01-01 00:00:00"
      # Change the time value appropriately
      TM=`echo "(${i}-${IYEAR})*365 + ${DAYS[${k}-1]}" | bc`
      LB=`echo "(${i}-${IYEAR})*365 + ${MIN_DAYS[${k}-1]}" | bc`
      UB=`echo "(${i}-${IYEAR})*365 + ${MAX_DAYS[${k}-1]}" | bc`
      echo "Source Year: ${MYEAR}, Month ${k}; Target Year: ${i}, Month ${k}: ${LB} ${TM} ${UB}"
      SFNAME=${CASE}.${MODEL}.${HIST}.${MYEAR}-${MON}.nc
      TFNAME=${CASE}.${MODEL}.${HIST}.${YR}-${MON}.nc
      rm -f ${TFNAME}
      ncap2 -s "time(0)=${TM};time_bounds(0,0)=(${LB});time_bounds(0,1)=(${UB})" ${SFNAME} ${TFNAME}
      ncatted -O -a units,time,o,c,"days since ${IYEAR}-01-01 00:00:00" ${TFNAME}
    done
  done
done
