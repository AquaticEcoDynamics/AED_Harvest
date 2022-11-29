#!/bin/bash

. ./common/start.sh

URL="https://kumina.water.wa.gov.au/waterinformation/wir/reports/publish/"

TODAY=`date +%Y%m%d`

DATADIR="data/${YEAR}/harvest_wir/"

for WHICH in 6163414 6163441 6163948 6163949 6163950 6163951 6164394 6164648 6164677 6164685 ; do

  if [ ! -f ${DATADIR}/dbca_${WHICH}/${TODAY}.csv ] ; then
    wget -q ${URL}${WHICH}/db5.zip --user-agent="" -O db5.zip >& /dev/null

    mkdir tmpx_$$
    cd tmpx_$$
    unzip ../db5.zip

    if [ `ls -l *.csv | wc -l` -eq 1 ] ; then
      mkdir -p ../${DATADIR}/dbca_${WHICH}
      mv *.csv ../${DATADIR}/dbca_${WHICH}/${TODAY}.csv
    fi

    cd ..
    /bin/rm -rf tmpx_$$

    /bin/rm db5.zip
  fi

done

exit 0
