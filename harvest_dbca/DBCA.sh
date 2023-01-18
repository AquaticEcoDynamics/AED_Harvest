#!/bin/bash

. ./security/ftp.x
. ./common/start.sh

FTP_SITE="ftp://ftp.see.uwa.edu.au/data/"

case $SITENAME in
  "sce")
     COLLECT=sce
     ;;
   *) # none?
     echo unknown site \"${SITENAME}\" specified\?
     exit 0
     ;;
esac

URL="${FTP_SITE}dbca/sites"
DATADIR="data/${YEAR}/harvest_dbca/${COLLECT}/"

TMPPRE="/tmp/tmpx$$_"
TMPLST=${TMPPRE}Lst

#==============================================================================#

makeiso () {
  date=`echo $1 | cut -f2 -d\ `
  time=`echo $1 | cut -f1 -d\ `

  day=`echo $date | cut -f1 -d/`
  mnth=`echo $date | cut -f2 -d/`
  year=`echo $date | cut -f3 -d/`

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
curl --user ${USERNAME}:${PASSWORD} --list-only "${URL}/" -s -o $TMPLST

mkdir -p ${DATADIR} > /dev/null 2>&1

#grep "${YEAR}-${MONTH}-${DAY}" $TMPLST | while read LINE ; do
cat  $TMPLST | while read LINE ; do
    FILE=`echo $LINE | tr -d '\r'`
    DIRN=`echo ${FILE} | sed -e 's/\.csv$//'`
    DIRN="${DIRN}-"`echo $FILE | cut -f5 -d_`
#   echo Fetching $FILE into ${DATADIR}/${DIRN}
    mkdir -p ${DATADIR}/${DIRN} > /dev/null 2>&1
    curl --user ${USERNAME}:${PASSWORD} "${URL}/${FILE}" -s -o ${DATADIR}/${DIRN}/${TODAY}.csv
done

/bin/rm $TMPLST

. ./common/finish.sh
exit 0

#------------------------------------------------------------------------------#

SEARCH="${DAY}/${MONTH}/${YEAR}"

cat $TMPLST | while read LINE ; do
    FILE=`echo $LINE | tr -d '\r'`
#   echo Fetching ${FILE}
    curl --user ${USERNAME}:${PASSWORD} "${URL}/${FILE}" -s -o ${DATADIR}/${FILE}
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
           CURLAST=$ISODT
           set_data_date "$NEWDT"
           log_last_data
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
done

/bin/rm $TMPLST
#------------------------------------------------------------------------------#

. ./common/finish.sh

exit 0
