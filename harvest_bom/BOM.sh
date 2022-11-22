#!/bin/bash

DEBUG=0
NOW=`date +%Y%m%d%H%M`
TODAY=`date +%Y%m%d`

case $1 in
  "barrack")   # Barrack St
     URL="http://www.bom.gov.au/fwo/IDW62404/IDW62404.509440.tbl.shtml"
     COLLECT=bom_barrack
     ;;
  "meadow")    # Meadow St
     URL="http://www.bom.gov.au/fwo/IDW62404/IDW62404.509378.tbl.shtml"
     COLLECT=bom_meadow
     ;;
  "kent")      # Kent St
     URL="http://www.bom.gov.au/fwo/IDW62404/IDW62404.509484.tbl.shtml"
     COLLECT=bom_kent
     ;;
   *) # none?
     exit 0
     ;;
esac

if [ $DEBUG -eq 0 ] ; then
  FILE=tmpx.$$
else
  FILE=tmpx.bom
fi

# a small subroutine to convert date data from "DD/MM/YYY HH:mm" to
# isodate format (YYYYMMDDHHmm) for easy comparison
#
# NB: remember to call with date in quotes
makeiso () {
  date=$1
  day=`echo $date | cut -f1 -d/`
  mnth=`echo $date | cut -f2 -d/`
  year=`echo $date | cut -f3 -d/ | cut -f1 -d\ `

  time=`echo $date | cut -f2 -d\ `
  hour=`echo $time | cut -f1 -d:`
  min=`echo $time | cut -f2 -d:`

  ISODATE=$year$mnth$day$hour$min
# echo $ISODATE
}


ARCHIVEF="data/${COLLECT}/${TODAY}.csv"
COLLECTF="${COLLECT}_${TODAY}.csv"
/bin/mkdir -p "data/${COLLECT}"

ISODATE=0
if [ -f $ARCHIVEF ] ; then
  # if file exists, get the last line and decode its date entry
  LAST=`tail -1 $ARCHIVEF | cut -f1 -d,`
# echo LAST = $LAST
  makeiso "$LAST"
  LASTENTRY=$ISODATE
else
  LASTENTRY=000000000000
fi
#echo LASTENTRY = $LASTENTRY


# for debugging we use a local file called bom.html - otherwise get it off the net
if [ $DEBUG -eq 0 ] ; then
  wget -q $URL --user-agent="" -O $FILE >& /dev/null
fi

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
      fi
      read line
      if [ $? -eq 0 ] ; then
        TIDE=`echo $line | cut -f2 -d\> | cut -f1 -d\<`
      fi
      read line

      # date format is : 24/11/2021 08:31
      makeiso "$DATE"

      if [ $ISODATE -gt $LASTENTRY ] ; then
      # echo Adding "$DATE,$TIDE"
        if [ ! -f $ARCHIVEF ] ; then
          echo "date,tide" > $ARCHIVEF
        fi
        echo "$DATE,$TIDE" >> $ARCHIVEF
#       if [ ! -f $COLLECTF ] ; then
#         echo "date,tide" > $COLLECTF
#       fi
#       echo "$DATE,$TIDE" >> $COLLECTF
      fi
    fi
  fi
done
}

# This will extract the body of the table :
#
#    tr -d '\r' < $FILE | sed -n '/<tbody/,/<\/tbody/p'

tr -d '\r' < $FILE | sed -n '/<tbody/,/<\/tbody/p' | do_table_rows


if [ $DEBUG -eq 0 ] ; then
  # if we got it off the net we can remove it
  /bin/rm $FILE
fi
