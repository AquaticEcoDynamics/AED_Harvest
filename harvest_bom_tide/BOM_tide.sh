#!/bin/bash

. ./common/start.sh

DATADIR="data/${YEAR}/harvest_bom_tide"

TMPFILE="/tmp/tmpx$$_bom_tide"

URL="http://www.bom.gov.au/ntc/IDO71012/IDO71012_${YEAR}.csv"

# Date & UTC Time,Sea Level,Water Temperature,Air Temperature,Barometric Pressure,Residuals,Adjusted Residuals,Wind Direction,Wind Gust,Wind Speed,Hillarys
# 01-Jan-2021 00:00, 0.568,  24.5,  23.2, 1011.0, 0.165, 0.142,  166,   5.9,   2.1

wget -q $URL --user-agent="" -O $TMPFILE

if [ $? -eq 0 ] ; then
  line=`head -1 $TMPFILE`
  HEADER="DateTime,`echo $line | cut -f2- -d,`"

# echo MYSTART=$MYSTART MYEND=$MYEND

  grep -v Date $TMPFILE | while read line ; do
    DATE=`echo $line | cut -f1 -d,`
    ISODATE=`date --date="$DATE" +%Y%m%d%H%M%S`
#   echo DATE=$DATE ISODATE=$ISODATE

    if [ $MYSTART -lt $ISODATE ] ; then
      if [ $MYEND -lt $ISODATE ] ; then
#       echo found end
        break;
      fi
      if [ ! -f ${DATADIR}/${OUTFILE} ] ; then
        if [ ! -d ${DATADIR} ] ; then
          /bin/mkdir -p ${DATADIR}
        fi
        echo $HEADER > ${DATADIR}/${OUTFILE}
      fi
      date=`to_std_time_fmt $ISODATE`
      line=`echo $line | cut -f2- -d,`
      echo $date,$line >> ${DATADIR}/${OUTFILE}
    fi
  done

# echo done $TMPFILE for $MYSTART to $MYEND
  /bin/rm $TMPFILE
fi

. ./common/finish.sh
