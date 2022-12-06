#!/bin/bash

. ./common/start.sh

case $SITENAME in
   "fremantle")
     URL="https://www.transport.wa.gov.au/imarine/fremantle-fishing-boat-harbour-tide.asp"
     COLLECT="dot_fremantle"
     ;;
   "barrack")
     URL="https://www.transport.wa.gov.au/imarine/perth-barrack-street-tide.asp"
     COLLECT="dot_barrack"
     ;;
   "peel")
     URL="https://www.transport.wa.gov.au/imarine/peel-inlet-tide.asp"
     COLLECT="dot_peel"
     ;;
   "mandurah")
     URL="https://www.transport.wa.gov.au/imarine/mandurah-tide.asp"
     COLLECT="dot_mandurah"
     ;;
   "mozzie")
     URL="https://www.transport.wa.gov.au/imarine/department-of-health-wa-mosquito-management-program.asp"
     COLLECT="dot_mozzie"
     ;;
   *)
     exit 0
     ;;
esac

DATADIR="data/${YEAR}/harvest_dot/${COLLECT}"
mkdir -p ${DATADIR} >& /dev/null

if [ "$DEBUG" != "true" ] ; then
  FILE=tmpx.$$
else
  if [ "$SITENAME" = "mozzie" ] ; then
    FILE=tmpx.moz
  else
    FILE=tmpx.dot
  fi
fi

makemonth () {
  case $1 in
    "Jan") mnth="01" ;;
    "Feb") mnth="02" ;;
    "Mar") mnth="03" ;;
    "Apr") mnth="04" ;;
    "May") mnth="05" ;;
    "Jun") mnth="06" ;;
    "Jul") mnth="07" ;;
    "Aug") mnth="08" ;;
    "Sep") mnth="09" ;;
    "Oct") mnth="10" ;;
    "Nov") mnth="11" ;;
    "Dec") mnth="12" ;;
    *)     mnth="--" ;;
  esac
}

makeiso () {
  # format was Tues 23rd Nov 2021 11:15hrs
  day=`echo $1 | cut -f2 -d\  | cut -b1-2 | sed 's/[a-z]*//g'`
  if [ $day -lt 10 ] ; then
    day="0$day"
  fi
  month=`echo $1 | cut -f3 -d\  `
  makemonth $month
  year=`echo $1 | cut -f4 -d\  `

  time=`echo $1 | cut -f5 -d\  | cut -b1-5`
  hour=`echo $time | cut -f1 -d\:`
  mins=`echo $time | cut -f2 -d\:`

  ISODATE=$year$mnth$day$hour$mins
  FMTDATE="$year-$mnth-$day $hour:$mins"
}

lastiso () {
  date=$1
  year=`echo $date | cut -f1 -d-`
  mnth=`echo $date | cut -f2 -d-`
  day=`echo $date | cut -f3 -d- | cut -f1 -d\ `

  time=`echo $date | cut -f2 -d\ `
  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`

  echo $year$mnth$day$hour$min
}


if [ "$DEBUG" != "true" ] ; then
  wget -q $URL -O $FILE >& /dev/null
fi

# This extract the "paragraph" containing 'Recorded Tide' where blank lines are paragraph markers
#DATASECT=`tr -d '\r' < $FILE | sed -e '/./{H;$!d;}' -e 'x;/Recorded Tide:/!d'`

# The old way gets the tide data, but only for the first instance
#TIDED=`tr -d '\r' < $FILE | sed -n '/Recorded Tide/,$p' | sed -n '2p' | cut -f3 -d \> | cut -f1 -d\< | tr '\n' '\|'`

# So, the new way gets the line numbers on which "Recorded Tide" appears, the line after which has the tide data
TLNX=`grep -n 'Recorded Tide:' $FILE | cut -f1 -d\: | tr '\n' '\|'`

UPDATED=`tr -d '\r' < $FILE | sed -e '/./{H;$!d;}' -e 'x;/Recorded Tide:/!d' | grep Updated | cut -f2 -d\> | cut -f1 -d\< | cut -f2- -d\  | tr '\n' '\|'`
RESIDUAL=`tr -d '\r' < $FILE | sed -e '/./{H;$!d;}' -e 'x;/Recorded Tide:/!d' | grep Residual: | cut -f5 -d\> | cut -f1 -d\< | tr '\n' '\|'`
PREDICTED=`tr -d '\r' < $FILE | sed -e '/./{H;$!d;}' -e 'x;/Recorded Tide:/!d' | grep Predicted: | cut -f5 -d\> | cut -f1 -d\< | tr '\n' '\|'`

NAMES=`tr -d '\r' < $FILE | grep 'anchor-margin'| cut -f8 -d\> | cut -f1 -d\< | tr '\n' '\|'`

# Count the number of times a paragraph of Recorded Tide appears
COUNTS=`tr -d '\r' < $FILE | sed -e '/./{H;$!d;}' -e 'x;/Recorded Tide:/!d' | grep Updated | cut -f2 -d\> | cut -f1 -d\< | cut -f2- -d\  | wc -l`

# echo Counted is $COUNTS

# echo Updated is \"$UPDATED\"
# # echo Tide is \"$TIDED\"
# echo lines for tides \"$TLNX\"
# echo Residual is \"$RESIDUAL\"
# echo Predicted is \"$PREDICTED\"
# # echo

# echo "=============================="
I=0
while [ $I -lt $COUNTS ] ; do
  I=$((I+1))

  NAME=`echo $NAMES | cut -f${I} -d\|`
  NAME=`echo $NAME | tr ' ' '\n' | grep -v 'tidal' | grep -v 'data' | tr '\n' ' '`
  NAME=`echo $NAME`
  NAME=`echo $NAME | tr ' ' '_' | tr "[:upper:]" "[:lower:]"`

  makeiso "`echo $UPDATED | cut -f${I} -d\|`"
  log_last_data "$FMTDATE"

  LN=`echo $TLNX | cut -f${I} -d\|`
  TIDE=`tr -d '\r' < $FILE | sed -n "$((LN+1))p" | cut -f3 -d \> | cut -f1 -d\< `

  RESID=`echo $RESIDUAL | cut -f${I} -d\|  | tr -dc '0123456789\-\.'`
  PRED=`echo $PREDICTED | cut -f${I} -d\|  | tr -dc '0123456789\-\.'`

# echo Name is \"$NAME\"
# echo Updated is \"$UPDT\"
# echo Tide is \"$TIDE\"
# echo Residual is \"$RESID\"
# echo Predicted is \"$PRED\"

  if [ $COUNTS -gt 1 ] ; then
    COLLECT=moz_${NAME}
  fi

# echo Collect is \"$COLLECT\"
  ARCHIVEF="${DATADIR}/${TODAY}.csv"
  /bin/mkdir -p "${DATADIR}" >& /dev/null

  if [ -f $ARCHIVEF ] ; then
    # if file exists, get the last line and decode its date entry
    LAST=`tail -1 $ARCHIVEF | cut -f1 -d,`
#echo last in $ARCHIVEF is $LAST
    LASTENTRY=`lastiso "$LAST"`
  else
    LASTENTRY=0
  fi

# echo Last was \"$LASTENTRY\" now is \"$ISODATE\"

  if [ $ISODATE -gt $LASTENTRY ] ; then
#   echo Adding "$FMTDATE,$TIDE,$RESID,$PRED"
    if [ ! -f $ARCHIVEF ] ; then
      echo "date,tide,residual,predicted" > $ARCHIVEF
    fi
    echo "$FMTDATE,$TIDE,$RESID,$PRED" >> $ARCHIVEF
    log_last_update
  fi

# echo "=============================="
done

/bin/rm $FILE

. ./common/finish.sh

exit 0
