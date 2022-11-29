#!/bin/bash

. ./common/start.sh

TMPFILE="/tmp/tmpx$$_mdba.tmp"

#echo SITENAME in \"$SITENAME\"
case "$SITENAME" in
  "Alexandrina")
     export sitefile="lkalex"
     ;;
  "Albert")
     export sitefile="lkalbert"
     ;;
  "Lock 1 Upstream")
     export sitefile="a4260902"
     ;;
  "Lock 1 Downstream")
     export sitefile="a4260903"
     ;;
  *)
     export sitefile="lkalex"
     SITENAME="Alexandrina"
     ;;
esac

#echo sitefile is \"$sitefile\" from SITENAME \"$SITENAME\"
SITENAME=`echo $SITENAME | tr ' ' '-' | tr [A-Z] [a-z]`
#echo site now $SITENAME
DATADIR="data/${YEAR}/harvest_mdba/${SITENAME}/"

#echo fetch \"https://riverdata.mdba.gov.au/sites/default/files/liveriverdata/csv/${sitefile}.csv\"
curl -X GET https://riverdata.mdba.gov.au/sites/default/files/liveriverdata/csv/${sitefile}.csv -s -o ${TMPFILE}

to_mdba_time_fmt () {
  # Takes one argument a date/time in YYYYmmddHHMMSS format and produces "YYYY-mm-dd HH:MM"
  echo "`echo $1 | cut -c7-8`/`echo $1 | cut -c5-6`/`echo $1 | cut -c1-4`"
}

SEARCH="`to_mdba_time_fmt $TODAY`"
#echo  search for \"$SEARCH\"
VALUE=`grep $SEARCH  ${TMPFILE} | cut -f2 -d,`

if [ "$VALUE" = "" ] ; then
  /bin/rm ${TMPFILE}
  curl -X GET https://riverdata.mdba.gov.au/sites/default/files/liveriverdata/csv/${sitefile}_historical.csv -s -o ${TMPFILE}
  VALUE=`grep $SEARCH  ${TMPFILE} | cut -f2 -d,`
  if [ "$VALUE" = "" ] ; then
    # no data for this date
    /bin/rm ${TMPFILE}
    exit
  fi
fi

TIMEV=`grep $SEARCH  ${TMPFILE} | cut -f1 -d,`

DTV="${YEAR}${MONTH}${DAY}`echo $TIMEV | cut -c1-2``echo $TIMEV | cut -c4-5`00"

LTIME=`to_std_time_fmt $DTV`

if [ ! -d ${DATADIR} ] ; then
  mkdir -p ${DATADIR}
fi

if [ ! -f "${DATADIR}/${ISODATE}.csv" ] ; then
  echo "Time,Value" > ${DATADIR}/${ISODATE}.csv
  echo "${LTIME},${VALUE}" >> ${DATADIR}/${ISODATE}.csv
fi

/bin/rm ${TMPFILE}

. ./common/finish.sh

exit 0
