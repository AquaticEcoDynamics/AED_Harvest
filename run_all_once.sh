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

    echo harvest_bom barrack $BACKTIME
    ./harvest_bom/BOM.sh $BACKTIME --site barrack
    sleep 1
    echo harvest_bom meadow $BACKTIME
    ./harvest_bom/BOM.sh $BACKTIME --site meadow
    sleep 1
    echo harvest_bom kent $BACKTIME
    ./harvest_bom/BOM.sh $BACKTIME --site kent
    sleep 1
    echo harvest_bom lake alexandrina $BACKTIME
    ./harvest_bom/BOM.sh $BACKTIME --site alex
    sleep 1
    echo harvest_bom river murray lock 1 $BACKTIME
    ./harvest_bom/BOM.sh $BACKTIME --site murray1
    sleep 1
    echo harvest_bom river murray lock 6 $BACKTIME
    ./harvest_bom/BOM.sh $BACKTIME --site murray6

#   echo harvest_bom jacup
#   ./harvest_bom/BOM.sh $BACKTIME --site jacup

    echo harvest_bom_tide $BACKTIME
    ./harvest_bom_tide/BOM_tide.sh $BACKTIME

    echo harvest_dot fremantle $BACKTIME
    ./harvest_dot/DOT.sh $BACKTIME --site fremantle
    echo harvest_dot barrack $BACKTIME
    ./harvest_dot/DOT.sh $BACKTIME --site barrack
    echo harvest_dot peel $BACKTIME
    ./harvest_dot/DOT.sh $BACKTIME --site peel
    echo harvest_dot mandurah $BACKTIME
    ./harvest_dot/DOT.sh $BACKTIME --site mandurah
    echo harvest_dot mozzie $BACKTIME
    ./harvest_dot/DOT.sh $BACKTIME --site mozzie

    echo harvest_dot_aws $BACKTIME
    ./harvest_dot_aws/DOTAWS.sh $BACKTIME

    echo harvest_neon $BACKTIME
    ./harvest_neon/NEON.sh $BACKTIME

    echo harvest_matilda $BACKTIME
    ./harvest_matilda/MATILDA.sh $BACKTIME

    echo harvest_dpird $BACKTIME
#   ./harvest_dpird/DPIRD.sh $BACKTIME
    ./harvest_dpird/DPIRD.sh $BACKTIME --site SP
    ./harvest_dpird/DPIRD.sh $BACKTIME --site DP001
    ./harvest_dpird/DPIRD.sh $BACKTIME --site QA001
    ./harvest_dpird/DPIRD.sh $BACKTIME --site MS001
    ./harvest_dpird/DPIRD.sh $BACKTIME --site GA001
    ./harvest_dpird/DPIRD.sh $BACKTIME --site DK001


    echo harvest_lwn $BACKTIME
    ./harvest_lwn/LWN.sh $BACKTIME

    echo harvest_mdba $BACKTIME
    ./harvest_mdba/MDBA.sh $BACKTIME --site Albert
    ./harvest_mdba/MDBA.sh $BACKTIME --site Alexandrina
    ./harvest_mdba/MDBA.sh $BACKTIME --site "Lock 1 Upstream"
    ./harvest_mdba/MDBA.sh $BACKTIME --site "Lock 1 Downstream"

    echo harvest_dwer $BACKTIME
    ./harvest_dwer/DWER.sh $BACKTIME --site cockburn
    ./harvest_dwer/DWER.sh $BACKTIME --site flow

#   ./harvest_dbca/DBCA.sh $BACKTIME --site sce
    ./harvest_wiski/WISKI.sh $BACKTIME

    echo harvest_wir $BACKTIME
    ./harvest_wir/WIR.sh $BACKTIME

# DEW.sh takes a very long time (more than an hour) to run
# so leave it out for now
#   echo harvest_dew $BACKTIME
#   ./harvest_dew/DEW.sh $BACKTIME

exit 0
