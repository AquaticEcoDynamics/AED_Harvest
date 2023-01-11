#!/bin/sh

cd /Data/AED_Harvest/data/log

echo -n > status.html
cat << EOF >> status.html
<HTML>
<HEAD>
<TITLE>AED Harvester Status Summary</TITLE>
</HEAD>
<BODY>
<TABLE>
<TR><TH>Site</TH><TH>Last Run</TH><TH>Last Update</TH><TH>Last Data</TH></TR>
EOF

for i in *; do
  if [ -d $i ] ; then
    RUN=`cat $i/last_run 2> /dev/null`
    UPD=`cat $i/last_update 2> /dev/null`
    DAT=`cat $i/last_data 2> /dev/null`
    echo '<TR><TD>'$i'</TD><TD>'$RUN'</TD><TD>'$UPD'</TD><TD>'$DAT'</TD></TR>' >> status.html
  fi
done

cat << EOF >> status.html
</TABLE>
</BODY>
</HTML>
EOF
