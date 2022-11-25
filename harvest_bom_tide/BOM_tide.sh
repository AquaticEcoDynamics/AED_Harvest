#!/bin/bash

DEBUG=0

NOW=`date +%Y%m%d`
DATADIR="data/`date +%Y`/harvest_bom_tide"
OUTFILE=${DATADIR}/${NOW}.csv

URL="http://www.bom.gov.au/ntc/IDO71012/IDO71012_2021.csv"

if [ ! -d ${DATADIR} ] ; then
   mkdir ${DATADIR}
fi
if [ $DEBUG -eq 0 ] ; then
  wget -q $URL --user-agent="" -O $OUTFILE >& /dev/null
fi


