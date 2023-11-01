#!/bin/bash
#
# harvest_wir/WIR.sh

. ./common/start.sh

URL="https://kumina.water.wa.gov.au/waterinformation/wir/reports/publish/"

DATADIR="data/${YEAR}/harvest_wir/"

SRCHDATE="${DAY}/${MONTH}/${YEAR}"
export IGNORE='"", 255,"", 255,"", 255,"", 255,"", 255,"", 255,"", 255'

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
      export OUTWHICH=$WHICH$TST

#     echo FILE=$file TST=\"$TST\" OUTWHICH=$OUTWHICH LT=$LT
      if [ -d ${CWD}/${DATADIR}/dbca_${OUTWHICH} ] ; then
        list="${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_*.csv"
        if [ "$list" != "" ] ; then
          for fl in $list ; do
            /bin/rm $fl
          done
        fi
      fi

      grep "$SRCHDATE" $file | while read line ; do
        TIME=`echo $line | cut -f1 -d,`
        LTIME=`mk_std_time "$TIME"`

        VALS=`echo $line | cut -f2- -d, | tr -d '\r'`
        if [ "$VALS" != "$IGNORE" ] ; then
          ### only create dir and header if there is actually data to add
          if [ ! -d ${CWD}/${DATADIR}/dbca_${OUTWHICH} ] ; then
            mkdir -p ${CWD}/${DATADIR}/dbca_${OUTWHICH}
          fi

          if [ ! -f ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_.csv ] ; then
            head -4 $file > ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_.csv
          fi
          ### to here

          echo ${LTIME},${VALS} >> ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_.csv
        else
          touch ${TMPDIR}/ignored
        fi
      done
    done

    if [ ! -f ${TMPDIR}/ignored ] ; then
      /bin/mv ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_.csv ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}.csv
    else
      LAST_TIME=""
      NLN=`wc -l ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_.csv | cut -f1 -d\ `
      if [ $NLN -gt 1 ] ; then
        LAST_TIME=`tail -1 ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_.csv | \
                                     cut -f1 -d, | cut -f2 -d\ | tr -d ':'`
 #      echo "Last time is ${LAST_TIME}"
        /bin/mv ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_.csv ${CWD}/${DATADIR}/dbca_${OUTWHICH}/${TODAY}_${LAST_TIME}.csv
      fi
    fi
    cd ${CWD}

    /bin/rm -rf ${TMPDIR}
    /bin/rm ${TMPFILE}
# else
#   echo wget failed
  fi
done

. ./common/finish.sh

exit 0
