#!/bin/bash
#
# harvest_matilda/MATILDA.sh
#
. ./security/matilda.x
. ./common/start.sh

FILETMP="/tmp/tmpx$$_matilda"

#ISODATE=`date --date=-1day +%Y%m%d`
#STARTTIME=`date --date=-1day +%F`T00:00:00
#ENDTIME=`date +%F`T00:00:00
ISODATE=${YEAR}${MONTH}${DAY}
STARTTIME="${YEAR}-${MONTH}-${DAY}T00:00:00"
ENDTIME="${YEAR}-${MONTH}-${DAY}T23:59:59"
#echo ISODATE=\"$ISODATE\"
#echo STARTTIME=\"$STARTTIME\"
#echo ENDTIME=\"$ENDTIME\"

HOST="https://api.eagle.io/api/v1/nodes"
COUNT=0

# 5c47e70fe4b0944321ed7fa1 is "Dissolved Oxygen mgL-1"
# 5c47e70ee4b0944321ed7f99 is "Dissolved Oxygen Sat"
# 5c5387e0e4b00017b3e18b22 is "ORP"
# 5c47e70de4b0944321ed7f8b is "pH"
# 5c47e70ce4b0944321ed7f85 is "Salinity psu"
# 5c47e70ce4b0944321ed7f80 is "Specific Conductivity uS"
# 5c47e71ae4b0944321ed8039 is "System - batt-volt"
# 5c47e71be4b0944321ed8042 is "System - GPS-Lat"
# 5c47e71be4b0944321ed8046 is "System - GPS-Long"
# 5c47e71ae4b0944321ed803d is "System - PTemp"
# 5c47e70ce4b0944321ed7f7b is "Temperature"
# 5c47e70ee4b0944321ed7f93 is "Turbidity-NTU"
# 5c47e710e4b0944321ed7faa is "Wiper-V"
# 5c47e713e4b0944321ed7fd0 is "Met-24HrData - Air-Temp-Avg"
# 5c47e714e4b0944321ed7fd4 is "Met-24HrData - Air-Temp-Max"
# 5c47e714e4b0944321ed7fdd is "Met-24HrData - Air-Temp-Min"
# 5c47e715e4b0944321ed7fe1 is "Met-24HrData - Air-Temp-TMn"
# 5c47e714e4b0944321ed7fd8 is "Met-24HrData - Air-Temp-TMx"
# 5c47e716e4b0944321ed7ffb is "Met-24HrData - Baro-Pressure-Avg"
# 5c47e715e4b0944321ed7fe6 is "Met-24HrData - Rel-Hum-Avg"
# 5c47e710e4b0944321ed7fb0 is "Met-24HrData - Wind-Speed-Avg"
# 5c47e718e4b0944321ed8017 is "Met-HrData - Air-Temp-Avg"
# 5c47e718e4b0944321ed8020 is "Met-HrData - Baro-Pressure-Avg"
# 5c47e718e4b0944321ed801c is "Met-HrData - Rel-Hum-Avg"
# 5c47e718e4b0944321ed8012 is "Met-HrData - Wind-Speed-Avg"
# 5c47e719e4b0944321ed802c is "Met-IntervalData - Air-Temp-Avg"
# 5c47e71ae4b0944321ed8035 is "Met-IntervalData - Baro-Pressure-Avg"
# 5c47e719e4b0944321ed8031 is "Met-IntervalData - Rel-Hum-Avg"
# 5c47e719e4b0944321ed8028 is "Met-IntervalData - Wind-Speed-Avg"
# 5c47e719e4b0944321ed8024 is "Met-IntervalData - Wind-Dir-Avg"

absent_nodes=( '5c47e715e4b0944321ed7fe1'  \
               '5c47e714e4b0944321ed7fd8'  )

met_nodes=( '5c47e713e4b0944321ed7fd0'  \
            '5c47e714e4b0944321ed7fd4'  \
            '5c47e714e4b0944321ed7fdd'  \
            '5c47e716e4b0944321ed7ffb'  \
            '5c47e715e4b0944321ed7fe6'  \
            '5c47e710e4b0944321ed7fb0'  \
            '5c47e718e4b0944321ed8017'  \
            '5c47e718e4b0944321ed8020'  \
            '5c47e718e4b0944321ed801c'  \
            '5c47e718e4b0944321ed8012'  \
            '5c47e719e4b0944321ed802c'  \
            '5c47e71ae4b0944321ed8035'  \
            '5c47e719e4b0944321ed8031'  \
            '5c47e719e4b0944321ed8028'  \
            '5c47e719e4b0944321ed8024'  )

wq_nodes=(  '5c47e70fe4b0944321ed7fa1'  \
            '5c47e70ee4b0944321ed7f99'  \
            '5c5387e0e4b00017b3e18b22'  \
            '5c47e70de4b0944321ed7f8b'  \
            '5c47e70ce4b0944321ed7f85'  \
            '5c47e70ce4b0944321ed7f80'  \
            '5c47e70ce4b0944321ed7f7b'  \
            '5c47e70ee4b0944321ed7f93'  \
            '5c47e710e4b0944321ed7faa'  )

sys_nodes=( '5c47e71ae4b0944321ed8039'  \
            '5c47e71be4b0944321ed8042'  \
            '5c47e71be4b0944321ed8046'  \
            '5c47e71ae4b0944321ed803d'  )


#------------------------------------------------------------------------------#
append_csv() {
   SRCFILE=$2
   if [ -f ${SRCFILE} ] ; then
     LINE=`head -1 ${SRCFILE}`
     LINE=${LINE},\"$1\"
   else
     LINE=Time,\"$1\"
   fi
   echo $LINE > x_${SRCFILE}
   while read LINE ; do
      tag=`echo $LINE | cut -f2 -d\"`
      if [ "$tag" = "data" ] ; then
         break
      fi
   done
   while read LINE ; do
     tag=`echo ${LINE} | cut -f2 -d\"`
     if [ "$tag" = "ts" ] ; then
       TIME=`echo $LINE | cut -f4 -d\" | tr -d '-' | tr -d ':' | tr -d 'T' | cut -f1 -d\.`
       VALU=`echo $LINE | cut -f11 -d\" | cut -f2 -d\: | cut -f1 -d\}`
#      echo $TIME $VALU
       if [ -f ${SRCFILE} ] ; then
         LINE=`grep $TIME ${SRCFILE}`
       else
         LINE=""
       fi
       if [ "$LINE" = "" ] ; then
         LINE=$TIME
         TC=0
         while [ $TC -lt $COUNT ] ; do
            LINE=${LINE},
            TC=$((TC+1))
         done
       fi
       LINE=${LINE},$VALU
       echo $LINE >> x_${SRCFILE}
     fi
   done

   if [ -f ${SRCFILE} ] ; then
     /bin/rm ${SRCFILE}
   fi
   /bin/mv x_${SRCFILE} ${SRCFILE}
}

#------------------------------------------------------------------------------#
OUTFILE=me.csv

DATADIR="data/${YEAR}/harvest_matilda/"
if [ ! -d ${DATADIR} ] ; then
   mkdir -p ${DATADIR}
fi
for dir in uwa_met_matilda uwa_wq_matilda uwa_sys_matilda ; do
   if [ ! -d ${DATADIR}/$dir ] ; then
      mkdir -p ${DATADIR}/$dir
   fi
done

COUNT=0

for node in ${met_nodes[*]} ; do
#  echo $node
   URL="${HOST}/${node}/historic/?startTime=${STARTTIME}Z&endTime=${ENDTIME}Z"

   wget -O ${FILETMP}_${node} -q --header="X-Api-Key:${api_key}" ${URL}

   NAME=`grep -w name ${FILETMP}_${node} | cut -f2 -d: | cut -f2 -d\"`

#  echo "===================" >> xx
#  echo ${node} is \"$NAME\" >> xx
#  cat ${FILETMP}_${node} >> xx
#  echo "===================" >> xx

   cat ${FILETMP}_${node} | append_csv "$NAME" "${OUTFILE}"

#  cat ${OUTFILE} >> xx

   /bin/rm ${FILETMP}_${node}
   COUNT=$((COUNT+1))
done

/bin/mv ${OUTFILE} ${DATADIR}/uwa_met_matilda/${ISODATE}.csv

COUNT=0

for node in ${wq_nodes[*]} ; do
#  echo $node
   URL="${HOST}/${node}/historic/?startTime=${STARTTIME}Z&endTime=${ENDTIME}Z"

   wget -O ${FILETMP}_${node} -q --header="X-Api-Key:${api_key}" ${URL}

   NAME=`grep -w name ${FILETMP}_${node} | cut -f2 -d: | cut -f2 -d\"`
#  echo name is \"$NAME\"
   cat ${FILETMP}_${node} | append_csv "$NAME" "${OUTFILE}"
   /bin/rm ${FILETMP}_${node}
   COUNT=$((COUNT+1))
done

/bin/mv ${OUTFILE} ${DATADIR}/uwa_wq_matilda/${ISODATE}.csv

COUNT=0

for node in ${sys_nodes[*]} ; do
#  echo $node
   URL="${HOST}/${node}/historic/?startTime=${STARTTIME}Z&endTime=${ENDTIME}Z"

   wget -O ${FILETMP}_${node} -q --header="X-Api-Key:${api_key}" ${URL}

   NAME=`grep -w name ${FILETMP}_${node} | cut -f2 -d: | cut -f2 -d\"`
#  echo name is \"$NAME\"
   cat ${FILETMP}_${node} | append_csv "$NAME" "${OUTFILE}"
   /bin/rm ${FILETMP}_${node}
   COUNT=$((COUNT+1))
done

/bin/mv ${OUTFILE} ${DATADIR}/uwa_sys_matilda/${ISODATE}.csv

. ./common/finish.sh

exit 0
