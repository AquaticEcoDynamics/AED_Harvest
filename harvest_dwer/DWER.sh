#!/bin/bash

. ./security/ftp.x
. ./common/start.sh

FTP_SITE="ftp://ftp.see.uwa.edu.au/data/"

case $SITENAME in
  "cockburn")
     COLLECT=cockburn
     ;;
  "flow")
     COLLECT=dwer
     ;;
   *) # none?
     echo unknown site \"${SITENAME}\" specified\?
     exit 0
     ;;
esac

URL="${FTP_SITE}${COLLECT}"
DATADIR="data/${YEAR}/harvest_dwer/${SITENAME}/"

TMPPRE="/tmp/tmpx$$_"
TMPLST=${TMPPRE}Lst

#==============================================================================#

makeiso () {
  date=`echo $1 | cut -f2 -d\ `
  time=`echo $1 | cut -f1 -d\ `

  day=`echo $date | cut -f1 -d/`
  mnth=`echo $date | cut -f2 -d/`
  year=`echo $date | cut -f3 -d/`

  if [ "$day" = "$date" ] ; then
    day=`echo $date | cut -f1 -d-`
  fi
  if [ "$mnth" = "$date" ] ; then
    mnth=`echo $date | cut -f2 -d-`
  fi
  if [ "$year" = "$date" ] ; then
    year=`echo $date | cut -f3 -d-`
  fi

  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`

  echo ${year}${mnth}${day}${hour}${min}
}

makeiso2 () {
  date=`echo $1 | cut -f1 -d\ `
  time=`echo $1 | cut -f2 -d\ `

  day=`echo $date | cut -f1 -d/`
  mnth=`echo $date | cut -f2 -d/`
  year=`echo $date | cut -f3 -d/`

  if [ "$day" = "$date" ] ; then
    day=`echo $date | cut -f1 -d-`
  fi
  if [ "$mnth" = "$date" ] ; then
    mnth=`echo $date | cut -f2 -d-`
  fi
  if [ "$year" = "$date" ] ; then
    year=`echo $date | cut -f3 -d-`
  fi

  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`

  echo ${year}${mnth}${day}${hour}${min}
}

make_dt () {
  date=`echo $1 | cut -f2 -d\ `
  time=`echo $1 | cut -f1 -d\ `

  day=`echo $date | cut -f1 -d/`
  mnth=`echo $date | cut -f2 -d/`
  year=`echo $date | cut -f3 -d/`

  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`
  sec=`echo $time | cut -f3 -d:`

  echo ${year}-${mnth}-${day} ${hour}:${min}:${sec}
}

#------------------------------------------------------------------------------#
#echo curl --user ${USERNAME}:${PASSWORD} --list-only "${URL}/" -s -o ${TMPLST}
curl --user ${USERNAME}:${PASSWORD} --list-only "${URL}/" -s -o ${TMPLST}

if [ -f ${TMPLST} ] ; then
  T1=`date +"%Y%m%d"`
  if [ "$T1" = "$TODAY" ] ; then
    START=`date --date="${TODAY} -1day" +%Y/%m/%d`
  else
    START=`date --date="${TODAY}" +%Y/%m/%d`
  fi
  YEAR=`echo $START | cut -f1 -d/`
  MONTH=`echo $START | cut -f2 -d/`
  DAY=`echo $START | cut -f3 -d/`

  mkdir -p ${DATADIR} > /dev/null 2>&1

  if [ "$SITENAME" = "flow" ] ; then
    grep "${YEAR}-${MONTH}-${DAY}" ${TMPLST} | while read LINE ; do
        FILE=`echo $LINE | tr -d '\r'`
        DIRN=`echo $FILE | cut -f1 -d~`
        DIRN="${DIRN}-"`echo $FILE | cut -f2 -d~`
        DIRN="${DIRN}-"`echo $FILE | cut -f3 -d~`
        DIRN="${DIRN}-"`echo $FILE | cut -f4 -d~`
        DIRN="${DIRN}-"`echo $FILE | cut -f5 -d~`
#       echo Fetching $FILE into ${DATADIR}/${DIRN}
        mkdir -p ${DATADIR}/${DIRN} > /dev/null 2>&1
        curl --user ${USERNAME}:${PASSWORD} "${URL}/${FILE}" -s -o ${DATADIR}/${DIRN}/${TODAY}.csv
    done

    /bin/rm ${TMPLST}

    . ./common/finish.sh
    exit 0
  fi

#------------------------------------------------------------------------------#

  SEARCH="${DAY}/${MONTH}/${YEAR}"

  cat ${TMPLST} | while read LINE ; do
    FILE=`echo $LINE | tr -d '\r'`
    curl --user ${USERNAME}:${PASSWORD} "${URL}/${FILE}" -s -o ${DATADIR}/${FILE}
    if [ -f ${DATADIR}/${FILE} ] ; then
      DIRN=`echo ${FILE} | sed -e 's/\.csv$//'`
      if [ "${DIRN}" != "${FILE}" ] ; then
        mkdir -p ${DATADIR}/${DIRN} > /dev/null 2>&1
        if [ -f ${DATADIR}/${DIRN}/${TODAY}.csv ] ; then
          TCL=`tail -1 ${DATADIR}/${DIRN}/${TODAY}.csv | cut -f1 -d,`
          export CURLAST=`makeiso2 "$TCL"`
        else
          export CURLAST=000000000000
        fi

        echo -n > ${DATADIR}/${DIRN}/${TODAY}.csv
        grep "${SEARCH}" ${DATADIR}/${FILE} | while read L2 ; do
           INDT=`echo $L2 | cut -f1 -d,`
           REST=`echo $L2 | cut -f2- -d,`
           ISODT=`makeiso "$INDT"`
           NEWDT=`make_dt "$INDT"`

           if [ $ISODT -gt $CURLAST ] ; then
             echo $NEWDT,$REST >> ${DATADIR}/${DIRN}/${TODAY}.csv
             set_data_date "$NEWDT"
             log_last_update

             CURLAST=$ISODT
           fi
        done

        count=`wc -l ${DATADIR}/${DIRN}/${TODAY}.csv | cut -f1 -d\ `
        if [ $count -eq 0 ] ; then
           /bin/rm ${DATADIR}/${DIRN}/${TODAY}.csv
           /bin/rmdir ${DATADIR}/${DIRN} > /dev/null 2>&1
        fi
      else
        echo unexpected file \"${FILE}\"
      fi

      /bin/rm ${DATADIR}/${FILE}
    fi
  done

  /bin/rm ${TMPLST}
#------------------------------------------------------------------------------#
fi

. ./common/finish.sh

exit 0
