#!/bin/bash
#
# harvest_dew/DEW.sh
#
. ./common/start.sh

FILE=/tmp/tmpx$$

SITECODE=A4261002
UNIT_ID=241


DATADIR="data/${YEAR}/harvest_dew/${SITECODE}"

BASESITE="https://water.data.sa.gov.au/Export/BulkExport?"

# Curiously, asking for 100days of data returns way more - all the way back to 2011
#QUERY="DateRange=Days7"
#QUERY="DateRange=Days100"
QUERY="DateRange=Custom"
QUERY=${QUERY}"&StartTime=${YYEAR}-${YMONTH}-${YDAY}%2000%3A00"
QUERY=${QUERY}"&EndTime=${TYEAR}-${TMONTH}-${TDAY}%2023%3A59"
QUERY=${QUERY}"&TimeZone=9.5"
QUERY=${QUERY}"&Calendar=CALENDARYEAR"
#QUERY=${QUERY}"&Interval=Daily"
QUERY=${QUERY}"&Interval=Hourly"
QUERY=${QUERY}"&Step=1&ExportFormat=csv"
QUERY=${QUERY}"&TimeAligned=True"
QUERY=${QUERY}"&RoundData=False"
QUERY=${QUERY}"&IncludeGradeCodes=False"
QUERY=${QUERY}"&IncludeApprovalLevels=False"
QUERY=${QUERY}"&IncludeInterpolationTypes=False"
QUERY=${QUERY}"&Datasets[0].DatasetName=Discharge.Total%20barrage%20flow%40${SITECODE}"
QUERY=${QUERY}"&Datasets[0].Calculation=Aggregate"
QUERY=${QUERY}"&Datasets[0].UnitId=${UNIT_ID}"
QUERY=${QUERY}"&_=1636421128724"
URL="${BASESITE}${QUERY}"

#echo ${QUERY}
#echo $URL

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
#cat $FILE
#/bin/rm $FILE
#exit

if [ $? -eq 0 ] ; then
  if [ -f $FILE ] ; then
    grep "^${SRCHDATE}" $FILE | while read LINE ; do
#     echo \"${LINE}\"
      if [ "$LINE" != "" ] ; then
        DATE=`echo $LINE | cut -f1 -d,`
        FLOW=`echo $LINE | cut -f3 -d,` 
        if [ $FLOW != "NaN" ] ; then
          if [ ! -f ${ARCHIVEF} ] ; then
            if [ ! -d ${DATADIR} ] ; then
              mkdir -p ${DATADIR}
            fi
            echo "Date,Flow" > ${ARCHIVEF}
          fi
          echo "${DATE}, $FLOW" >> ${ARCHIVEF}
          log_last_update
        fi
#     else
#       echo no line
      fi
    done

    # if we got it off the net we can remove it
    /bin/rm $FILE
# else
#   echo no file
  fi
#else
# echo fetch failed
fi

. ./common/finish.sh
