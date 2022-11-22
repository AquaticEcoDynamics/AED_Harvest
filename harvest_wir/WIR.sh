#!/bin/bash

URL="https://kumina.water.wa.gov.au/waterinformation/wir/reports/publish/"

NOW=`date +%Y%m%d%H%M`
TODAY=`date +%Y%m%d`

for WHICH in 6163414 6163441 6163948 6163949 6163950 6163951 6164394 6164648 6164677 6164685 ; do

  if [ ! -f data/dbca_${WHICH}/${TODAY}.csv ] ; then
    wget -q ${URL}${WHICH}/db5.zip --user-agent="" -O db5.zip >& /dev/null

    mkdir tmpx_$$
    cd tmpx_$$
    unzip ../db5.zip

    if [ `ls -l *.csv | wc -l` -eq 1 ] ; then
      mkdir -p ../data/dbca_${WHICH}
      mv *.csv ../data/dbca_${WHICH}/${TODAY}.csv
    fi

    cd ..
    /bin/rm -rf tmpx_$$

    /bin/rm db5.zip
  fi

done

exit 0
