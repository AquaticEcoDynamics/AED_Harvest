#!/bin/bash
#
# harvest_dew/DEW.sh
#
. ./common/start.sh

DATADIR="data/${YEAR}/harvest_dew/barrage"

FILE=/tmp/tmpx$$

# Curiously, asking for 100days of data returns way more - all the way back to 2011
BASESITE="https://water.data.sa.gov.au/Export/BulkExport?"
#QUERY="DateRange=Days30"
QUERY="DateRange=Days100"
QUERY=${QUERY}"&TimeZone=9.5"
QUERY=${QUERY}"&Calendar=CALENDARYEAR"
QUERY=${QUERY}"&Interval=Daily"
QUERY=${QUERY}"&Step=1&ExportFormat=csv"
QUERY=${QUERY}"&TimeAligned=True"
QUERY=${QUERY}"&RoundData=False"
QUERY=${QUERY}"&IncludeGradeCodes=False"
QUERY=${QUERY}"&IncludeApprovalLevels=False"
QUERY=${QUERY}"&IncludeInterpolationTypes=False"
QUERY=${QUERY}"&Datasets[0].DatasetName=Discharge.Total%20barrage%20flow%40A4261002"
QUERY=${QUERY}"&Datasets[0].Calculation=Aggregate"
QUERY=${QUERY}"&Datasets[0].UnitId=241"
QUERY=${QUERY}"&_=1636421128724"
URL="${BASESITE}${QUERY}"

# a small subroutine to convert date data from "YYYY-mm-dd HH:MM" to
# isodate format (YYYYMMDDHHmm) for easy comparison
#
# NB: remember to call with date in quotes
makeiso () {
  date=`echo $1 | cut -f1 -d\ `
  time=`echo $1 | cut -f2 -d\ `

  year=`echo $date | cut -f1 -d-`
  mnth=`echo $date | cut -f2 -d-`
  day=`echo $date | cut -f3 -d-`

  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`

  echo ${year}${mnth}${day}${hour}${min}
}


SRCHDATE="${YEAR}-${MONTH}-${DAY}"
ARCHIVEF="${DATADIR}/${TODAY}.csv"


# Fetch the data file
wget -q $URL --user-agent="" -O $FILE

if [ $? -eq 0 ] ; then
  if [ -f $FILE ] ; then
    LINE=`grep "^${SRCHDATE}" $FILE` 
    if [ "$LINE" != "" ] ; then
      FLOW=`echo $LINE | cut -f3 -d,` 
      if [ ! -d ${DATADIR} ] ; then
        mkdir -p ${DATADIR}
      fi
      echo "Date,Flow" > ${ARCHIVEF}
      echo "${SRCHDATE} 00:00, $FLOW" >> ${ARCHIVEF}
#   else
#     echo no line
    fi

    # if we got it off the net we can remove it
    /bin/rm $FILE
# else
#   echo no file
  fi
#else
# echo fetch failed
fi

. ./common/finish.sh
