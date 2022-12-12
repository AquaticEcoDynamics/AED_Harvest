#!/bin/sh
#
# harvest_dew/DEW.sh
#
. ./common/start.sh

export MYLOGFILE="${LOGDIR}/`date +'%Y%m%d%H%M'`.log"

export FILE=/tmp/tmpx$$

export SRCHDATE="${YEAR}-${MONTH}-${DAY}"

#export BASESITE="https://water.data.sa.gov.au/Export/BulkExport?"
export BASESITE="https://water.data.sa.gov.au/Export/DataSet?"

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


process_site ()
{
  SITECODE="$1"
  UNIT_ID="$2"
  DATASET="$3"
  URL="$4"
  URL="${URL}&_=1636421128724"

# echo SITE "$SITECODE"  DATASET "$DATASET" UNIT_ID "$UNIT_ID"

  DATADIR="data/${YEAR}/harvest_dew/${SITECODE}-`echo $DATASET | sed -e 's/%20/_/g'`"

  ARCHIVEF="${DATADIR}/${TODAY}.csv"

  RIGHTNOW=`date "+%Y-%m-%d %H:%M:%S"`
  DAYNOW=`date "+%Y%m%d"`
  URLVERS=1

  # Fetch the data file
  curl -X GET "${URL}" -s -o $FILE
  if [ $? -ne 0 ] ; then
    URLVERS=2

    QUERY="DataSet=${DATASET}%40${SITECODE}"
    # If now start/end time specified it should return full data set
#   if [ "$TODAY" = "$DAYNOW" ] ; then
#     QUERY=${QUERY}"&StartTime=${YYEAR}-${YMONTH}-${YDAY}%2000%3A00"
#     QUERY=${QUERY}"&EndTime=${TYEAR}-${TMONTH}-${TDAY}%2023%3A59"
#   fi
    # This is much quicker than "The whole set" but will fail on backfill before last week
    QUERY=${QUERY}"&DateRange=Days7"
    QUERY=${QUERY}"&ExportFormat=csv"
    QUERY="${QUERY}&Compressed=false"
    QUERY=${QUERY}"&RoundData=False"
    QUERY=${QUERY}"&TimeZone=9.5"
    URL="${BASESITE}${QUERY}"

    curl -X GET "${URL}" -s -o $FILE
  fi

  if [ $? -eq 0 ] ; then

    echo $RIGHTNOW fetch OK with form $URLVERS url for SITE "$SITECODE" DATASET "$DATASET" UNIT_ID "$UNIT_ID" >> ${MYLOGFILE}

    if [ -f $FILE ] ; then
      grep "^${SRCHDATE}" $FILE | while read LINE ; do
        if [ "$LINE" != "" ] ; then
          DATE=`echo $LINE | tr -d '\r' | cut -f1 -d,`
          VALU=`echo $LINE | tr -d '\r' | cut -f3 -d,`
          if [ $VALU != "NaN" ] ; then
            if [ ! -f ${ARCHIVEF} ] ; then
              if [ ! -d ${DATADIR} ] ; then
                mkdir -p ${DATADIR}
              fi
              echo "Date,Value" > ${ARCHIVEF}
            fi
            echo "${DATE}, $VALU" >> ${ARCHIVEF}
            log_last_update
          fi
        fi
      done

      # if we got it off the net we can remove it
      /bin/rm $FILE
      if [ -f ${ARCHIVEF} ] ; then
        head -1 ${ARCHIVEF} > $FILE
        tail -n+2 ${ARCHIVEF} | sort -u >> $FILE
        /bin/rm ${ARCHIVEF}
        /bin/mv $FILE ${ARCHIVEF}
      else
        echo $RIGHTNOW no data for $TODAY '@' SITE "$SITECODE" DATASET "$DATASET" >> ${MYLOGFILE}
      fi
    fi
  else
    echo $RIGHTNOW fetch failed on both forms for SITE "$SITECODE"  DATASET "$DATASET" UNIT_ID "$UNIT_ID" >> ${MYLOGFILE}
#   echo \"$4\" >> ${MYLOGFILE}
#   echo \"$URL\" >> ${MYLOGFILE}
  fi
}


#===============================================================================
URL='https://water.data.sa.gov.au/Export/BulkExport?'
URL="${URL}DateRange=Custom"
URL="${URL}&StartTime=2022-12-10%2000%3A00"
URL="${URL}&EndTime=2022-12-12%2023%3A59"
URL="${URL}&TimeZone=9.5"
URL="${URL}&Calendar=CALENDARYEAR"
URL="${URL}&Interval=Hourly"
URL="${URL}&Step=1"
URL="${URL}&ExportFormat=csv"
URL="${URL}&TimeAligned=True"
URL="${URL}&RoundData=False"
URL="${URL}&IncludeGradeCodes=False"
URL="${URL}&IncludeApprovalLevels=False"
URL="${URL}&IncludeInterpolationTypes=False"
URL="${URL}&Datasets[0].DatasetName=Discharge.Total%20barrage%20flow%40A4261002"
URL="${URL}&Datasets[0].Calculation=Aggregate"
URL="${URL}&Datasets[0].UnitId=241"
#URL="${URL}&_=1636421128724"

SITECODE=A4261002
UNIT_ID=241
DATASET='Discharge.Total%20barrage%20flow'

#NEXTONE=`date --date="-3mins" "+%Y%m%d%H%M%S"`

NEXTONE=`date --date="+20secs" "+%Y%m%d%H%M%S"`
process_site "$SITECODE" "$UNIT_ID" "$DATASET" "$URL"

sort -u harvest_dew/theaddress.txt | while read LINE ; do
   SITECODE=`echo $LINE | tr -d '\r' | cut -f1 -d,`
   URL=`echo $LINE | tr -d '\r' | cut -f2- -d,`
   DATASET=`echo $URL | tr '&' '\n' | grep DatasetName | cut -f2 -d= | sed -e 's/%40/\@/' | cut -f1 -d\@`
   UNIT_ID=`echo $URL | tr '&' '\n' | grep UnitId | cut -f2 -d=`

   THISONE=`date "+%Y%m%d%H%M%S"`
   if [ $THISONE -lt $NEXTONE ] ; then
     sleep 15
   fi
   NEXTONE=`date --date="+20secs" "+%Y%m%d%H%M%S"`
   process_site "$SITECODE" "$UNIT_ID" "$DATASET" "$URL"
done

. ./common/finish.sh

exit 0
