#!/bin/bash

. ./security/lwn.x
. ./common/start.sh

WEBSITE="https://api.awsnetwork.com.au/v3/"
LOGINPATH="auth/login"

TMPPRE="/tmp/tmpx_$$_"
TMPGRP=${TMPPRE}SGrps

H1="Content-Type: application/json"

#------------------------------------------------------------------------------#

CREDENTIALS="{\"email\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}"
# echo "curl -X POST ${WEBSITE}${LOGINPATH} -H \"${H1}\" -d ${CREDENTIALS} -s"
RESPONSE=`curl -X POST ${WEBSITE}${LOGINPATH} -H "${H1}" -d ${CREDENTIALS} -s`
# echo RESPONSE was \"$RESPONSE\"

TOKEN=`echo $RESPONSE | cut -f1 -d, | cut -f2 -d: | tr -d '\"'`
H2="Authorization: Bearer ${TOKEN}"

# echo "curl -X GET "${WEBSITE}sensor-groups" -H \"${H1}\" -H \"${H2}\" -s -o $TMPGRP"
curl -X GET "${WEBSITE}sensor-groups" -H "${H1}" -H "${H2}" -s -o $TMPGRP

STATLN=`sed -e 's/{/\n{\n/g' -e 's/}/\n}\n/g' < $TMPGRP | grep '"name":"15 minute data"'`
echo $STATLN | tr ',' '\n' | grep '"stationName":' | cut -f2 -d\: | tr -d '"'

/bin/rm ${TMPGRP}
. ./common/finish.sh

exit 0
