#!/bin/bash
#
# This needs finishing

YEARS="2020 2021 2022 2023"
YEARS_r="2023 2022 2021 2020"

FROMD=""
TOD=""
REVERSE=""
COMMAND=""

while [ $# -gt 0 ] ; do
  case $1 in
# debug is not yet implemented
#   --debug)
#     export DEBUG=true
#     ;;
    --from)
      shift
      FROMD="$1"
      ;;
    --to)
      shift
      TOD="$1"
      ;;
    --command)
      shift
      COMMAND="$1"
      ;;
    --reverse | --backward)
      REVERSE="TRUE"
      ;;
    --help)
      echo "backfill.sh : run the harvesting to fill days gone by"
      echo "backfill.sh accepts :"
      echo "     \"--from YYYY-MM-DD\" : run from start date specified"
      echo "     \"--to YYYY-MM-DD\" :   run up to end date specified"
      echo "     \"--reverse\" :         run from end date down to start date"
      echo "     \"--command\" :         which script to run; eg :"
      echo "                                 --command ./harvest_wir/WIR"
      echo "                             default is ./run_all_once.sh"
      exit 0
      ;;
    *)
      ;;
  esac
  shift
done

#------------------------------------------------------------------------------#
if [ "$TOD" = "" ] ; then
  EOD=`date +"%Y%m%d"`
else
  EOD=`date --date="$TOD" +"%Y%m%d"`
fi
if [ "$FROMD" = "" ] ; then
  SOD=`date +"%Y0101"`
else
  SOD=`date --date="$FROMD" +"%Y%m%d"`
fi
if [ $SOD -gt $EOD ] ; then
  x=$SOD
  SOD=$EOD
  EOD=$x
fi
if [ `date +%Y%m%d` -lt $EOD ] ; then
  EOD=`date +%Y%m%d`
fi
#echo SOD=\"$SOD\" EOD=\"$EOD\"

if [ "$COMMAND" = "" ] ; then
  COMMAND="./run_all_once.sh"
fi

#------------------------------------------------------------------------------#
MONTHS="01 02 03 04 05 06 07 08 09 10 11 12"
MONTHS_r="12 11 10 09 08 07 06 05 04 03 02 01"

#------------------------------------------------------------------------------#
leap_year() {
  leap=$1
  if [ `expr $leap % 400` -eq 0 ] ; then
    echo 'Y'
  elif [ `expr $leap % 100` -eq 0 ] ; then
    echo 'N'
  elif [ `expr $leap % 4` -eq 0 ] ; then
    echo 'Y'
  else
    echo 'N'
  fi
}
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
days_in_month () {
 case $1 in
   01) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ;;
   02) if [ "`leap_year $2`" = "Y" ] ; then
          echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
       else
          echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28
       fi ;;
   03) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ;;
   04) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30    ;;
   05) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ;;
   06) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30    ;;
   07) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ;;
   08) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ;;
   09) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30    ;;
   10) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ;;
   11) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30    ;;
   12) echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ;;
 esac
}
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
days_in_month_r () {
 case $1 in
   01) echo 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   02) if [ "`leap_year $2`" = "Y" ] ; then
          echo 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01
       else
          echo    28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01
       fi ;;
   03) echo 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   04) echo    30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   05) echo 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   06) echo    30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   07) echo 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   08) echo 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   09) echo    30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   10) echo 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   11) echo    30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
   12) echo 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ;;
 esac
}
#------------------------------------------------------------------------------#

if [ "$REVERSE" = "TRUE" ] ; then
  for year in $YEARS_r ; do
    for month in $MONTHS_r ; do
      for day in `days_in_month_r $month $year` ; do
         if [ $SOD -le $year$month$day ] ; then
           if [ $EOD -ge $year$month$day ] ; then
             $COMMAND --today $year-$month-$day
           fi
         fi
      done
    done
  done
else
  for year in $YEARS ; do
    for month in $MONTHS ; do
      for day in `days_in_month $month $year` ; do
         if [ $SOD -le $year$month$day ] ; then
           if [ $EOD -ge $year$month$day ] ; then
             $COMMAND --today $year-$month-$day
           fi
         fi
      done
    done
  done
fi


exit 0
