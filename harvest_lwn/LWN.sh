#!/bin/bash

. ../security/lwn.x

ISODATE=`date +%Y%m%d`

WEBSITE="https://api.awsnetwork.com.au/v3/"
LOGINPATH="auth/login"

SITENAME="Narrung"
DATADIR="data/${SITENAME}/"

TMPPRE="/tmp/tmpx_$$_"
TMPGRP=${TMPPRE}SGrps
TMPLST=${TMPPRE}Lst
TMPSNR=${TMPPRE}Snsr

H1="Content-Type: application/json"

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
   mkdir ${DATADIR} >& /dev/null

   sed -e 's/{/\n{\n/g' -e 's/}/\n}\n/g' < $TMPSNR | grep '"id":' | while read line ; do
     SID=`echo $line | tr ',' '\n' | grep '"id":' | cut -f2 -d\:`
     SNSRNM=`echo $line | tr ',' '\n' | grep '"sensorTypeName":' | cut -f2 -d\: | tr ' ' '_' | tr -d '"'`
     SNSRNM="${SNSRNM}_${SID}"
#    echo ${SNSRNM}
     mkdir ${DATADIR}/${SNSRNM} >& /dev/null

     if [ ! -f "${DATADIR}/${SNSRNM}/${ISODATE}.csv" ] ; then
       echo "Time,Timezone,Value" > ${DATADIR}/${SNSRNM}/${ISODATE}.csv
     else
       # might want to extract the last line time and only add later data
       LT=`tail -1 ${DATADIR}/${SNSRNM}/${ISODATE}.csv | cut -f1 -d,`
     fi
     if [ "$LT" = "" ] ; then
       LT="0"
     fi

     START=`date +%Y`"-01-01"
     END=`date +%Y-%m-%d`
     QUERY="start=${START}&end=${END}&perPage=1000000&page=1"

#    echo "curl -X GET "${WEBSITE}sensors/${SID}/readings?${QUERY}" -H "${H1}" -H "${H2}" -s -o ${TMPSNR}_${SID}"
     curl -X GET "${WEBSITE}sensors/${SID}/readings?${QUERY}" -H "${H1}" -H "${H2}" -s -o ${TMPSNR}_${SID}

     sed -e 's/{/\n{\n/g' -e 's/}/\n}\n/g' < ${TMPSNR}_${SID} | grep -w time | while read line ; do
       L2=`echo $line | tr ',' '\n' | grep -w time | cut -f2- -d\: | tr -d '"'`
       TIME=`echo $L2 | tr -d '-' | tr -d 'T' | tr -d ':' | cut -f1 -d\.`

       if [ $TIME -gt $LT ] ; then
         VALUE=`echo $line | tr ',' '\n' | grep -w value | cut -f2 -d\: | tr -d '"'`
         TIMEZONE=`echo $line | tr ',' '\n' | grep -w timezone | cut -f2 -d\: | tr -d '"'`

         echo "$TIME,$TIMEZONE,$VALUE" >> ${DATADIR}/${SNSRNM}/${ISODATE}.csv
       fi
     done
   done

   /bin/rm ${TMPPRE}*
exit
