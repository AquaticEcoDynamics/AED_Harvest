#!/bin/bash

DEBUG=0

# cd /ARMS/Workspaces/scevo/scevo/data/utils/web
cd /Data/AED_Harvest

BOM_NEXT=0
BOM_WAIT=30mins
BOMT_NEXT=0
BOMT_WAIT=1day
DOT_NEXT=0
DOT_WAIT=15mins
WIR_NEXT=0
WIR_WAIT=1day
NEONNEXT=0
NEONWAIT=1day
MATINEXT=0
MATIWAIT=1day
DPIRDNEXT=0
DPIRDWAIT=1day
LWN_NEXT=0
LWN_WAIT=12hours
MDBANEXT=0
MDBAWAIT=12hours
DEW_NEXT=0
DEW_WAIT=1day


# Use $RANDOM. It's often useful in combination with simple shell
# arithmetic. For instance, to generate a random number
# between 1 and 10 (inclusive):
#
#   $ echo $((1 + $RANDOM % 10))
#
#

while `true` ; do
  TODAY=`date`
  NOW=`date +%Y%m%d%H%M`

  if [ $NOW -ge $BOM_NEXT ] ; then
    # echo run BOM.sh
    ./harvest_bom/BOM.sh --site "barrack"
    sleep 1
    ./harvest_bom/BOM.sh --site "meadow"
    sleep 1
    ./harvest_bom/BOM.sh --site "kent"
    sleep 1
    ./harvest_bom/BOM.sh --site alex
    sleep 1
    ./harvest_bom/BOM.sh --site murray1
    sleep 1
    ./harvest_bom/BOM.sh --site murray6

    BOM_NEXT=`date +%Y%m%d%H%M --date="$TODAY + $BOM_WAIT"`
#   echo next BOM at $BOM_NEXT
  fi

  if [ $NOW -ge $BOMT_NEXT ] ; then
    ./harvest_bom_tide/BOM_tide.sh
    BOMT_NEXT=`date +%Y%m%d%H%M --date="$TODAY + $BOMT_WAIT"`
#   echo next BOMT at $BOMT_NEXT
  fi

  if [ $NOW -ge $DOT_NEXT ] ; then
    # echo run DOT.sh
    ./harvest_dot/DOT.sh --site "fremantle"
    ./harvest_dot/DOT.sh --site "barrack"
    ./harvest_dot/DOT.sh --site "peel"
    ./harvest_dot/DOT.sh --site "mandurah"
    ./harvest_dot/DOT.sh --site "mozzie"
    DOT_NEXT=`date +%Y%m%d%H%M --date="$TODAY + $DOT_WAIT"`
#   echo next DOT at $DOT_NEXT
  fi

  if [ $NOW -ge $WIR_NEXT ] ; then
    ./harvest_wir/WIR.sh
    WIR_NEXT=`date +%Y%m%d%H%M --date="$TODAY + $WIR_WAIT"`
#   echo next WIR at $WIR_NEXT
  fi

  if [ $NOW -ge $NEONNEXT ] ; then
    ./harvest_neon/NEON.sh
    NEONNEXT=`date +%Y%m%d%H%M --date="$TODAY + $NEONWAIT"`
#   echo next NEON at $NEONNEXT
  fi

  if [ $NOW -ge $MATINEXT ] ; then
    ./harvest_matilda/MATILDA.sh
    MATINEXT=`date +%Y%m%d%H%M --date="$TODAY + $MATIWAIT"`
#   echo next MATI at $MATINEXT
  fi

  if [ $NOW -ge $DPIRDNEXT ] ; then
    ./harvest_dpird/DPIRD.sh
    DPIRDNEXT=`date +%Y%m%d%H%M --date="$TODAY + $DPIRDWAIT"`
#   echo next DPIRD at $DPIRDNEXT

    DPIRDNEXT=0
    DPIRDWAIT=1day

  fi

  if [ $NOW -ge $LWN_NEXT ] ; then
    ./harvest_lwn/LWN.sh
    LWN_NEXT=`date +%Y%m%d%H%M --date="$TODAY + $LWN_WAIT"`
#   echo next LWN at $LWN_NEXT
  fi

  if [ $NOW -ge $MDBANEXT ] ; then
    ./harvest_mdba/MDBA.sh --site Albert
    ./harvest_mdba/MDBA.sh --site Alexandrina
    ./harvest_mdba/MDBA.sh --site "Lock 1 Upstream"
    ./harvest_mdba/MDBA.sh --site "Lock 1 Downstream"
    MDBANEXT=`date +%Y%m%d%H%M --date="$TODAY + $MDBAWAIT"`
#   echo next MDBA at $MDBANEXT
  fi

  if [ $NOW -ge $DEW_NEXT ] ; then
    ./harvest_dew/DEW.sh
    DEW_NEXT=`date +%Y%m%d%H%M --date="$TODAY + $DEW_WAIT"`
#   echo next DEW at $DEW_NEXT
  fi

  # sleep for a random time between 1 and 3 mins
  sleep $((60 + $RANDOM % 120))
done
