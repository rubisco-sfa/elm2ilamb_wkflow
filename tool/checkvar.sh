#!/usr/bin/env bash

module load nco

# NB: Untested on Csh, Ksh, Sh, Zsh! Send us feedback!
# Bash shell (/bin/bash), .bashrc examples
# ncattget $att_nm $var_nm $fl_nm : What attributes does variable have?
function ncattget { ncks --trd -M -m ${3} | grep -E -i "^${2} attribute [0-9]+: ${1}" | cut -f 11- -d ' ' | sort ; }
# ncunits $att_val $fl_nm : Which variables have given units?
function ncunits { ncks --trd -m ${2} | grep -E -i " attribute [0-9]+: units.+ ${1}" | cut -f 1 -d ' ' | sort ; }
# ncavg $var_nm $fl_nm : What is mean of variable?
function ncavg { ncwa -y avg -O -C -v ${1} ${2} ~/foo.nc ; ncks --trd -H -C -v ${1} ~/foo.nc | cut -f 3- -d ' ' ; }
# ncavg $var_nm $fl_nm : What is mean of variable?
function ncavg { ncap2 -O -C -v -s "foo=${1}.avg();print(foo)" ${2} ~/foo.nc | cut -f 3- -d ' ' ; }
# ncdmnlst $fl_nm : What dimensions are in file?
function ncdmnlst { ncks --cdl -m ${1} | cut -d ':' -f 1 | cut -d '=' -s -f 1 ; }
# ncvardmnlst $var_nm $fl_nm : What dimensions are in a variable?
function ncvardmnlst { ncks --trd -m -v ${1} ${2} | grep -E -i "^${1} dimension [0-9]+: " | cut -f 4 -d ' ' | sed 's/,//' ; }
# ncvardmnlatlon $var_nm $fl_nm : Does variable contain both lat and lon dimensions?
function ncvardmnlatlon { flg=`ncks -C -v ${1} -m ${2} | grep -E -i "${1}\(" | grep -E "lat.*lon|lon.*lat"` ; [[ ! -z "$flg" ]] && echo "Yes, ${1} has both lat and lon dimensions" || echo "No, ${1} does not have both lat and lon dimensions"; }
# ncdmnsz $dmn_nm $fl_nm : What is dimension size?
function ncdmnsz { ncks --trd -m -M ${2} | grep -E -i ": ${1}, size =" | cut -f 7 -d ' ' | uniq ; }
# ncgrplst $fl_nm : What groups are in file?
function ncgrplst { ncks -m ${1} | grep 'group:' | cut -d ':' -f 2 | cut -d ' ' -f 2 | sort ; }
# ncvarlst $fl_nm : What variables are in file?
function ncvarlst { ncks --trd -m ${1} | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort ; }
# ncmax $var_nm $fl_nm : What is maximum of variable?
function ncmax { ncwa -y max -O -C -v ${1} ${2} ~/foo.nc ; ncks --trd -H -C -v ${1} ~/foo.nc | cut -f 3- -d ' ' ; }
# ncmax $var_nm $fl_nm : What is maximum of variable?
function ncmax { ncap2 -O -C -v -s "foo=${1}.max();print(foo)" ${2} ~/foo.nc | cut -f 3- -d ' ' ; }
# ncmdn $var_nm $fl_nm : What is median of variable?
function ncmdn { ncap2 -O -C -v -s "foo=gsl_stats_median_from_sorted_data(${1}.sort());print(foo)" ${2} ~/foo.nc | cut -f 3- -d ' ' ; }
# ncmin $var_nm $fl_nm : What is minimum of variable?
function ncmin { ncap2 -O -C -v -s "foo=${1}.min();print(foo)" ${2} ~/foo.nc | cut -f 3- -d ' ' ; }
# ncrng $var_nm $fl_nm : What is range of variable?
function ncrng { ncap2 -O -C -v -s "foo_min=${1}.min();foo_max=${1}.max();print(foo_min,\"%f\");print(\" to \");print(foo_max,\"%f\")" ${2} ~/foo.nc ; }
# ncmode $var_nm $fl_nm : What is mode of variable?
function ncmode { ncap2 -O -C -v -s "foo=gsl_stats_median_from_sorted_data(${1}.sort());print(foo)" ${2} ~/foo.nc | cut -f 3- -d ' ' ; }
# ncrecsz $fl_nm : What is record dimension size?
function ncrecsz { ncks --trd -M ${1} | grep -E -i "^Root record dimension 0:" | cut -f 10- -d ' ' ; }
# nctypget $var_nm $fl_nm : What type is variable?
function nctypget { ncks --trd -m -v ${1} ${2} | grep -E -i "^${1}: type" | cut -f 3 -d ' ' | cut -f 1 -d ',' ; }
#-

if [[ -f "Omon_user.txt" ]]; then
   temp_omon=$(<"Omon_user.txt")
else
   temp_omon=()
fi

# remove duplicates
fldlist_omon=`echo $temp_omon | tr ' ' '\n' | sort -u | xargs`

if [ ! -z "$fldlist_omon" ]; then
   tmplst0=($fldlist_omon)
   tmplst1=''
   tmplst2=''
   for var in "${tmplst0[@]}"; do
       tmplst1="$tmplst1 timeMonthly_avg_$var"
       tmplst2="$tmplst2 timeMonthly_avg_ecosys_diag_$var"
   done

   fldlist_omon=($tmplst1 $tmplst2)
fi


SampleFile=/global/cfs/projectdirs/m3522/1pctco2_temp/20220102.HIST_RUBISCO_NEWSFLU_CNPCTC20TR_OIBGC.ne30_oECv3.compy/run/mpaso.hist.am.timeSeriesStatsMonthly.1850-01-01.nc
for var in "${fldlist_omon[@]}"; do
    rlt=(`ncvardmnlst $var $SampleFile 2>/dev/null`)
    if [[ ${#rlt[@]} < 3 && ${#rlt[@]} > 0 ]]; then
       echo $var
    fi
done

