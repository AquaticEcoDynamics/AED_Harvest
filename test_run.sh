#!/bin/bash

DEBUG=0

cd /Data/AED_Harvest

    echo harvest_bom barrack
    ./harvest_bom/BOM.sh "barrack"
    sleep 1
    echo harvest_bom meadow
    ./harvest_bom/BOM.sh "meadow"
    sleep 1
    echo harvest_bom kent
    ./harvest_bom/BOM.sh "kent"

    echo harvest_bom_tide
    ./harvest_bom_tide/BOM_tide.sh

    echo harvest_dot fremantle
    ./harvest_dot/DOT.sh "fremantle"
    echo harvest_dot barrack
    ./harvest_dot/DOT.sh "barrack"
    echo harvest_dot peel
    ./harvest_dot/DOT.sh "peel"
    echo harvest_dot mandurah
    ./harvest_dot/DOT.sh "mandurah"
    echo harvest_dot mozzie
    ./harvest_dot/DOT.sh "mozzie"

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

exit 0
