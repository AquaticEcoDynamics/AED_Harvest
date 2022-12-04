#!/bin/bash

. ./common/start.sh

URL="https://kumina.water.wa.gov.au/waterinformation/wir/reports/publish/"

DATADIR="data/${YEAR}/harvest_wir/"

mk_std_time () {
# convert from "03:50:00 01/09/2022" to "2022-09-01 03:50"
  date=`echo $1 | cut -f2 -d\ `
  time=`echo $1 | cut -f1 -d\ `

  day=`echo $date | cut -f1 -d/ `
  month=`echo $date | cut -f2 -d/`
  year=`echo $date | cut -f3 -d/`

  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`

  echo ${year}-${month}-${day} ${hour}:${min}
}

CWD=`pwd`

SRCHDATE="${DAY}/${MONTH}/${YEAR}"
IGNORE='"", 255,"", 255,"", 255,"", 255,"", 255,"", 255,"", 255'

for WHICH in 6163414 6163441 6163948 6163949 6163950 6163951 6164394 6164648 6164677 6164685 ; do

  TMPDIR=/tmp/tmpx$$_${WHICH}
  TMPFILE=/tmp/tmpx$$_${WHICH}_db5.zip

  wget -q ${URL}${WHICH}/db5.zip --user-agent="" -O ${TMPFILE} >& /dev/null

  if [ $? -eq 0 ] ; then
    mkdir ${TMPDIR}
    cd ${TMPDIR}
    unzip ${TMPFILE} >& /dev/null

    for file in *.csv ; do
      # extract only those lines for "today" and feed them into the while loop
      TST="`echo $file | cut -f7 -d~ | cut -f1 -d.`"
      OUTWHICH=$WHICH$TST
      if [ -f ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}.csv ] ; then
        LX=`tail -1 ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}.csv | cut -f1 -d,`
        LT=`date --date="$LX" +%Y%m%d%H%M%S`
      fi
      if [ "$LT" = "" ] ; then LT="0" ; fi
      if [ $LT -lt $MYSTART ] ; then LT=$MYSTART ; fi

#     echo FILE=$file TST=\"$TST\" OUTWHICH=$OUTWHICH LT=$LT

      grep "$SRCHDATE" $file | while read line ; do
        TIME=`echo $line | cut -f1 -d,`

        LTIME=`mk_std_time "$TIME"`
        LX=`date --date="$LTIME" +%Y%m%d%H%M%S`

#       echo LTIME=$LTIME LX=$LX LT=$LT
        if [ $LX -ge $LT ] ; then
          VALS=`echo $line | cut -f2- -d, | tr -d '\r'`
          if [ "$VALS" != "$IGNORE" ] ; then

            ### only create dir and header if there is actually data to add
            if [ ! -d ${CWD}/${DATADIR}/dbca_${OUTWHICH} ] ; then
              mkdir -p ${CWD}/${DATADIR}/dbca_${OUTWHICH}
            fi

            if [ ! -f ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}.csv ] ; then
              line=`head -4 $file`
              echo $line > ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}.csv
            fi
            ### to here

            echo ${LTIME},${VALS} >> ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}.csv
          fi
        fi
      done
    done

    cd ${CWD}

    /bin/rm -rf ${TMPDIR}
    /bin/rm ${TMPFILE}
# else
#   echo wget failed
  fi
done

. ./common/finish.sh

exit 0
