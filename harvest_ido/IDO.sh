#!/bin/bash

NOW=`date +%Y%m%d`
YEAR=`date +%Y`
OUTFILE=IDO71012_${YEAR}_${NOW}.csv

URL="http://www.bom.gov.au/ntc/IDO71012/IDO71012_${YEAR}.csv"

echo wget -q $URL --user-agent="" -O $OUTFILE
wget -q $URL --user-agent="" -O $OUTFILE >& /dev/null


