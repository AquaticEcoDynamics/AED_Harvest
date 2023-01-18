#!/bin/sh

CWD=`pwd`
cd data/log
OUTNAME=Status.md

echo -n > ${OUTNAME}
cat << EOF >> ${OUTNAME}
<TABLE>
<TR><TH>Site</TH><TH>Last Run</TH><TH>Last Update</TH><TH>Last Data</TH><TH>First Data</TH></TR>
EOF

for i in *; do
  if [ -d $i ] ; then
    RUN=`cat $i/last_run 2> /dev/null`
    UPD=`cat $i/last_update 2> /dev/null`
    DAT=`cat $i/last_data 2> /dev/null`
    SDT=`cat $i/start_data 2> /dev/null`
    echo '<TR><TD>'$i'</TD><TD>'$RUN'</TD><TD>'$UPD'</TD><TD>'$DAT'</TD><TD>'$SDT'</TD></TR>' >> ${OUTNAME}
  fi
done

echo '</TABLE>' >> ${OUTNAME}

cp ${OUTNAME} ${CWD}/../AED_Harvest.wiki
cd ${CWD}/../AED_Harvest.wiki
git pull
git commit -a -m 'update status'
git push
