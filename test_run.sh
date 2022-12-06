#!/bin/bash

TODAY=""
BACKTIME=""
DEBUG=false

while [ $# -gt 0 ] ; do
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --today)
      shift
      TODAY="$1"
      ;;
    *)
      ;;
  esac
  shift
done

if [ "$TODAY" != "" ] ; then
  Y=`echo $TODAY | cut -f1 -d-`
  if [ "$Y" = "$TODAY" ] ; then
    echo when asking for a specific date, please use \"--today YYYY-mm-dd\"
    exit 1
  fi
# M=`echo $TODAY | cut -f2 -d-`
# D=`echo $TODAY | cut -f3 -d-`
  BACKTIME="--today $TODAY"
fi

#echo BACKTIME is \"$BACKTIME\"

    echo harvest_bom barrack
    ./harvest_bom/BOM.sh $BACKTIME --site barrack
    sleep 1
    echo harvest_bom meadow
    ./harvest_bom/BOM.sh $BACKTIME --site meadow
    sleep 1
    echo harvest_bom kent
    ./harvest_bom/BOM.sh $BACKTIME --site kent
    sleep 1
    echo harvest_bom lake alexandrina
    ./harvest_bom/BOM.sh $BACKTIME --site alex
    sleep 1
    echo harvest_bom river murray lock 1
    ./harvest_bom/BOM.sh $BACKTIME --site murray1
    sleep 1
    echo harvest_bom river murray lock 6
    ./harvest_bom/BOM.sh $BACKTIME --site murray6

    echo harvest_bom_tide
    ./harvest_bom_tide/BOM_tide.sh $BACKTIME

    echo harvest_dot fremantle
    ./harvest_dot/DOT.sh $BACKTIME --site fremantle
    echo harvest_dot barrack
    ./harvest_dot/DOT.sh $BACKTIME --site barrack
    echo harvest_dot peel
    ./harvest_dot/DOT.sh $BACKTIME --site peel
    echo harvest_dot mandurah
    ./harvest_dot/DOT.sh $BACKTIME --site mandurah
    echo harvest_dot mozzie
    ./harvest_dot/DOT.sh $BACKTIME --site mozzie

    echo harvest_neon
    ./harvest_neon/NEON.sh $BACKTIME

    echo harvest_matilda
    ./harvest_matilda/MATILDA.sh $BACKTIME

    echo harvest_dpird
    ./harvest_dpird/DPIRD.sh $BACKTIME

    echo harvest_lwn
    ./harvest_lwn/LWN.sh $BACKTIME

    echo harvest_mdba
    ./harvest_mdba/MDBA.sh $BACKTIME --site Albert
    ./harvest_mdba/MDBA.sh $BACKTIME --site Alexandrina
    ./harvest_mdba/MDBA.sh $BACKTIME --site "Lock 1 Upstream"
    ./harvest_mdba/MDBA.sh $BACKTIME --site "Lock 1 Downstream"

#   if [ "$BACKTIME" = "" ] ; then
#     BACKTIME="--today `date +%Y-%m-%d --date=-1day`"
#   fi
    echo harvest_dew $BACKTIME
    ./harvest_dew/DEW.sh $BACKTIME

    echo harvest_wir $BACKTIME
    ./harvest_wir/WIR.sh $BACKTIME

exit 0
