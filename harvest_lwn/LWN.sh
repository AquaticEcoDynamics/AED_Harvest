#!/bin/bash

. ./security/lwn.x
. ./common/start.sh

WEBSITE="https://api.awsnetwork.com.au/v3/"
LOGINPATH="auth/login"

TMPPRE="/tmp/tmpx$$_"
TMPGRP=${TMPPRE}SGrps
TMPLST=${TMPPRE}Lst
TMPSNR=${TMPPRE}Snsr

H1="Content-Type: application/json"

if [ "$SITENAME" = "" ] ; then
  SITENAME="Narrung"
fi
DATADIR="data/${YEAR}/harvest_lwn/${SITENAME}/"

#------------------------------------------------------------------------------#
# Get all parameters at a site between start date and end date

   CREDENTIALS="{\"email\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}"
#  echo "curl -X POST ${WEBSITE}${LOGINPATH} -H \"${H1}\" -d ${CREDENTIALS} -s"
   RESPONSE=`curl -X POST ${WEBSITE}${LOGINPATH} -H "${H1}" -d ${CREDENTIALS} -s`
#  echo RESPONSE was \"$RESPONSE\"

   TOKEN=`echo $RESPONSE | cut -f1 -d, | cut -f2 -d: | tr -d '\"'`
   H2="Authorization: Bearer ${TOKEN}"

#  echo "curl -X GET "${WEBSITE}sensor-groups" -H \"${H1}\" -H \"${H2}\" -s -o $TMPGRP"
   curl -X GET "${WEBSITE}sensor-groups" -H "${H1}" -H "${H2}" -s -o $TMPGRP

   STATLN=`sed -e 's/{/\n{\n/g' -e 's/}/\n}\n/g' < $TMPGRP | grep $SITENAME | grep '"name":"15 minute data"'`
   SENSOR=`echo $STATLN | tr ',' '\n' | grep '"id":' | cut -f2 -d\:`
#  echo SENSOR = \"${SENSOR}\"

#  echo "curl -X GET "${WEBSITE}sensor-groups/${SENSOR}/sensors" -H "${H1}" -H "${H2}" -s -o $TMPSNR"
   curl -X GET "${WEBSITE}sensor-groups/${SENSOR}/sensors" -H "${H1}" -H "${H2}" -s -o $TMPSNR

   ## #get actual data
   mkdir -p ${DATADIR} >& /dev/null

   sed -e 's/{/\n{\n/g' -e 's/}/\n}\n/g' < $TMPSNR | grep '"id":' | while read line ; do
     SID=`echo $line | tr ',' '\n' | grep '"id":' | cut -f2 -d\:`
     SNSRNM=`echo $line | tr ',' '\n' | grep '"sensorTypeName":' | cut -f2 -d\: | tr ' ' '_' | tr -d '"'`
     SNSRNM="${SNSRNM}_${SID}"
#    echo ${SNSRNM}
     mkdir ${DATADIR}/${SNSRNM} >& /dev/null

     if [ ! -f "${DATADIR}/${SNSRNM}/${ISODATE}.csv" ] ; then
       echo "Time,Value" > ${DATADIR}/${SNSRNM}/${ISODATE}.csv
     else
       # might want to extract the last line time and only add later data
       LX=`tail -1 ${DATADIR}/${SNSRNM}/${ISODATE}.csv | cut -f1 -d,`
       LT=`date --date="$LX" +%Y%m%d%H%M%S`
     fi
     if [ "$LT" = "" ] ; then
       LT="0"
     fi
     if [ $LT -lt $MYSTART ] ; then
       LT=$MYSTART
     fi

     QUERY="start=${START}&end=${END}&perPage=1000000&page=1"

#    echo "curl -X GET "${WEBSITE}sensors/${SID}/readings?${QUERY}" -H "${H1}" -H "${H2}" -s -o ${TMPSNR}_${SID}"
     curl -X GET "${WEBSITE}sensors/${SID}/readings?${QUERY}" -H "${H1}" -H "${H2}" -s -o ${TMPSNR}_${SID}

     sed -e 's/{/\n{\n/g' -e 's/}/\n}\n/g' < ${TMPSNR}_${SID} | grep -w time | while read line ; do
       L2=`echo $line | tr ',' '\n' | grep -w time | cut -f2- -d\: | tr -d '"'`
       TIME=`echo $L2 | tr -d '-' | tr -d 'T' | tr -d ':' | cut -f1 -d\.`

       if [ $TIME -gt $MYEND ] ; then
#        echo breaking at time $TIME being greater than my end of $MYEND for sensor ${SID}
         break
       fi
       if [ $TIME -gt $LT ] ; then
         VALUE=`echo $line | tr ',' '\n' | grep -w value | cut -f2 -d\: | tr -d '"'`

         LTIME="`to_std_time_fmt $TIME`"
         echo "$LTIME,$VALUE" >> ${DATADIR}/${SNSRNM}/${ISODATE}.csv
         set_data_date "$LTIME"
         log_last_update
       fi
     done
   done

   /bin/rm ${TMPPRE}*

. ./common/finish.sh

exit
