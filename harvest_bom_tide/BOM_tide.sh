#!/bin/bash

DEBUG=0

NOW=`date +%Y%m%d`
OUTFILE=data/${NOW}.csv

URL="http://www.bom.gov.au/ntc/IDO71012/IDO71012_2021.csv"

if [ ! -d data ] ; then
   mkdir data
fi
if [ $DEBUG -eq 0 ] ; then
  wget -q $URL --user-agent="" -O $OUTFILE >& /dev/null
fi


