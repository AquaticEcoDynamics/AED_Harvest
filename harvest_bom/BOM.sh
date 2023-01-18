#!/bin/bash
#
# harvest_bom/BOM.sh
#
. ./common/start.sh

case $SITENAME in
  "barrack")   # Barrack St
     URL="http://www.bom.gov.au/fwo/IDW62404/IDW62404.509440.tbl.shtml"
     COLLECT=barrack
     ;;
  "meadow")    # Meadow St
     URL="http://www.bom.gov.au/fwo/IDW62404/IDW62404.509378.tbl.shtml"
     COLLECT=meadow
     ;;
  "kent")      # Kent St
     URL="http://www.bom.gov.au/fwo/IDW62404/IDW62404.509484.tbl.shtml"
     COLLECT=kent
     ;;
  "murray1")   # River Murray Upstream Lock 1
     URL="http://www.bom.gov.au/fwo/IDS60253/IDS60253.524504.tbl.shtml"
     COLLECT=murray1
     ;;
  "murray6")   # River Murray Upstream Lock 6
     URL="http://www.bom.gov.au/fwo/IDS60253/IDS60253.524038.tbl.shtml"
     COLLECT=murray6
     ;;
  "alex")      # Lake Alexandrina
     URL="http://www.bom.gov.au/fwo/IDS60253/IDS60253.524535.tbl.shtml"
     COLLECT=alex
     ;;
   *) # none?
     exit 0
     ;;
esac

DATADIR="data/${YEAR}/harvest_bom/${COLLECT}"

FILE=/tmp/tmpx$$

# a small subroutine to convert date data from "dd/mm/YYYY HH:MM" to
# isodate format (YYYYMMDDHHmm) for easy comparison
#
# NB: remember to call with date in quotes
makeiso () {
  date=`echo $1 | cut -f1 -d\ `
  time=`echo $1 | cut -f2 -d\ `

  day=`echo $date | cut -f1 -d/`
  mnth=`echo $date | cut -f2 -d/`
  year=`echo $date | cut -f3 -d/`

  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`

  echo ${year}${mnth}${day}${hour}${min}
}

# a small subroutine to convert date data from "YYYY-mm-dd HH:MM" to
# isodate format (YYYYMMDDHHmm) for easy comparison
makeiso2 () {
  date=`echo $1 | cut -f1 -d\ `
  time=`echo $1 | cut -f2 -d\ `

  year=`echo $date | cut -f1 -d-`
  mnth=`echo $date | cut -f2 -d-`
  day=`echo $date | cut -f3 -d-`

  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`

  echo ${year}${mnth}${day}${hour}${min}
}


SRCHDATE="${DAY}/${MONTH}/${YEAR}"
ARCHIVEF="${DATADIR}/${TODAY}.csv"

if [ -f $ARCHIVEF ] ; then
  # if file exists, get the last line and decode its date entry
  LAST=`tail -1 $ARCHIVEF | cut -f1 -d,`
# echo ARCHIVEF=$ARCHIVEF LAST=$LAST
  LASTENTRY=`makeiso2 "$LAST"`
else
  LASTENTRY=000000000000
fi

# Fetch the data file
wget -q $URL --user-agent="" -O $FILE

TITLE=`sed '/<title>/!d; /<\/title>/!d' < $FILE | cut -f2 -d\> | cut -f1 -d\<`

#echo Title is \"$TITLE\"

# A subroutine to read each line of the returned table and process it to produce the csv output
do_table_rows () {
while read line
do
  if [ "$line" != "" ] ; then

    if [ "$line" = "<tr>" ] ; then
      read line
      if [ "$line" = "" ] ; then read line ; fi
      if [ $? -eq 0 ] ; then
        DATE=`echo $line | cut -f2 -d\> | cut -f1 -d\<`
        TD=`echo $DATE | cut -f1 -d\ `
      fi
      read line
      if [ $? -eq 0 ] ; then
        TIDE=`echo $line | cut -f2 -d\> | cut -f1 -d\<`
      fi
      read line

      if [ "$TD" = "$SRCHDATE" ] ; then

        # date format is : 24/11/2021 08:31
        ISODATE=`makeiso "$DATE"`
#       echo DATE=$DATE ISODATE=$ISODATE LASTENTRY=$LASTENTRY

        if [ $ISODATE -gt $LASTENTRY ] ; then
        # echo Adding "$DATE,$TIDE"
          DATE=`to_std_time_fmt $ISODATE`
          if [ ! -f $ARCHIVEF ] ; then
            if [ ! -d ${DATADIR} ] ; then
              /bin/mkdir -p "${DATADIR}"
            fi
            echo "date,tide" > $ARCHIVEF
          fi
          echo "$DATE,$TIDE" >> $ARCHIVEF
          set_data_date "$DATE"
          log_last_update
        fi
      fi
    fi
  fi
done
}

# This will extract the body of the table :
#
#    tr -d '\r' < $FILE | sed -n '/<tbody/,/<\/tbody/p'

tr -d '\r' < $FILE | sed -n '/<tbody/,/<\/tbody/p' | do_table_rows


# if we got it off the net we can remove it
/bin/rm $FILE

. ./common/finish.sh
