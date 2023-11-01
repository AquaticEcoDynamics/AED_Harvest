#!/bin/bash

cd /Data/AED_Harvest

BNEXT=0

while `true` ; do
  NOW=`date +%Y%m%d%H%M`

  if [ $NOW -ge $BNEXT ] ; then
    FROMDT=`date --date="-1week" +%Y-%m-%d`
    TODATE=`date --date="-1day" +%Y-%m-%d`

    ./backfill.sh --from ${FROMDT} --to ${TODATE} --command ./harvest_wir/WIR.sh

    BNEXT=`date +%Y%m%d%H%M --date="6am + 1day"`
  fi

  sleep 1h
done
