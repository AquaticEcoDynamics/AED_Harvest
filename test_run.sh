#!/bin/bash

DEBUG=0

#cd /Data/AED_Harvest

    echo harvest_bom barrack
    ./harvest_bom/BOM.sh --site barrack
    sleep 1
    echo harvest_bom meadow
    ./harvest_bom/BOM.sh --site meadow
    sleep 1
    echo harvest_bom kent
    ./harvest_bom/BOM.sh --site kent

    echo harvest_bom_tide
    ./harvest_bom_tide/BOM_tide.sh

    echo harvest_dot fremantle
    ./harvest_dot/DOT.sh --site fremantle
    echo harvest_dot barrack
    ./harvest_dot/DOT.sh --site barrack
    echo harvest_dot peel
    ./harvest_dot/DOT.sh --site peel
    echo harvest_dot mandurah
    ./harvest_dot/DOT.sh --site mandurah
    echo harvest_dot mozzie
    ./harvest_dot/DOT.sh --site mozzie

    echo harvest_wir
    ./harvest_wir/WIR.sh

    echo harvest_neon
    ./harvest_neon/NEON.sh

    echo harvest_matilda
    ./harvest_matilda/MATILDA.sh

    echo harvest_dpird
    ./harvest_dpird/DPIRD.sh

    echo harvest_lwn
    ./harvest_lwn/LWN.sh

    echo harvest_mdba
    ./harvest_mdba/MDBA.sh --site Albert
    ./harvest_mdba/MDBA.sh --site Alexandrina
    ./harvest_mdba/MDBA.sh --site "Lock 1 Upstream"
    ./harvest_mdba/MDBA.sh --site "Lock 1 Downstream"

exit 0
