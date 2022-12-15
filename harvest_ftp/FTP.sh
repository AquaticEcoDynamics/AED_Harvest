#!/bin/bash

. ./security/ftp.x
. ./common/start.sh

FTP_SITE="ftp://ftp.see.uwa.edu.au/data/"

SITENAME=cockburn

TMPPRE="/tmp/tmpx$$_"
TMPLST=${TMPPRE}Lst

DATADIR="data/${YEAR}/harvest_ftp/${SITENAME}/"

#------------------------------------------------------------------------------#
   curl --user ${USERNAME}:${PASSWORD} --list-only "${FTP_SITE}${SITENAME}/" -s -o $TMPLST

   mkdir -p ${DATADIR} >& /dev/null
   cat $TMPLST | while read LINE ; do
     FILE=`echo $LINE | tr -d '\r'`
     echo Fetching ${FILE}
     curl --user ${USERNAME}:${PASSWORD} "${FTP_SITE}${SITENAME}/${FILE}" -s -o ${DATADIR}/${FILE}
   done

exit
