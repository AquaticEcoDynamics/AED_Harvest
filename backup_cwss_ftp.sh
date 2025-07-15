#!/bin/bash

. ./security/ftp.x

FTP_SITE="ftp://ftp.see.uwa.edu.au/data/"
URL="${FTP_SITE}cwss"

ISODATE=`date +"%Y%m%d"`
DATADIR="data/cwss/${ISODATE}/"

#==============================================================================#

#------------------------------------------------------------------------------#

mkdir -p ${DATADIR} > /dev/null 2>&1

CWD=`pwd`
cd ${DATADIR}
wget --no-verbose --no-parent --recursive --no-host-directories --user=${USERNAME} --password=${PASSWORD} ${URL}
cd ${CWD}

exit 0
