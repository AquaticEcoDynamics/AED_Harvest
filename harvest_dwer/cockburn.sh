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
     echo no \"site\" specified\?
     exit 0
     ;;
esac
URL="${FTP_SITE}${COLLECT}

TMPPRE="/tmp/tmpx$$_"
TMPLST=${TMPPRE}Lst

DATADIR="data/${YEAR}/harvest_dwer/${SITENAME}/"

#------------------------------------------------------------------------------#
   curl --user ${USERNAME}:${PASSWORD} --list-only "${URL}/" -s -o $TMPLST

   mkdir -p ${DATADIR} >& /dev/null
   cat $TMPLST | while read LINE ; do
     FILE=`echo $LINE | tr -d '\r'`
     echo Fetching ${FILE}
     curl --user ${USERNAME}:${PASSWORD} "${URL}/${FILE}" -s -o ${DATADIR}/${FILE}
   done
#------------------------------------------------------------------------------#

. ./common/finish.sh

exit
