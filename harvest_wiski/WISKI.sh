#!/bin/bash

. ./security/ftp.x
. ./common/start.sh

FTP_SITE="ftp://ftp.see.uwa.edu.au/data/"

#case $SITENAME in
#  "sce")
#     COLLECT=sce
#     ;;
#   *) # none?
#     echo unknown site \"${SITENAME}\" specified\?
#     exit 0
#     ;;
#esac

URL="${FTP_SITE}dbca/sites"
DATADIR="data/${YEAR}/harvest_wiski/"
#export base_dir="/buckets/scevo-data/arms/"
export base_dir="data_tmp/"

TMPPRE="/tmp/tmpx$$_"
TMPLST=${TMPPRE}Lst

#==============================================================================#

#------------------------------------------------------------------------------#
curl --user ${USERNAME}:${PASSWORD} --list-only "${URL}/" -s -o $TMPLST

mkdir -p ${DATADIR} > /dev/null 2>&1

cat  $TMPLST | while read LINE ; do
    FILE=`echo $LINE | tr -d '\r'`
    echo $FILE | grep '.csv$' > /dev/null 2>&1
    if [ $? -eq 0 ] ; then
      DFLN=`echo ${FILE} | cut -f-4 -d_`
      DFLN="${DFLN}.csv"
      DATED=`echo ${FILE} | cut -f4 -d_ | tr -d '-'`
      if [ $DATED -ge 20230907 ] ; then
        if [ -f ${DATADIR}/${DFLN} ] ; then
          echo Already got $FILE
        else
          echo Fetching $FILE into ${DATADIR}/${DFLN}
          curl --user ${USERNAME}:${PASSWORD} "${URL}/${FILE}" -s -o ${DATADIR}/${DFLN}
        fi
      fi
    fi
done

/bin/rm $TMPLST
count=0
for f in ${DATADIR}/* ; do
  if [ -f $f ] ; then
    MYDATE=`echo $f | cut -f4 -d_ | tr -d '-'`
    if [ $count -eq 0 ] ; then
      HEAD=`head -1 ${f} | tr -d '\r'`
      echo $HEAD,\"UploadDate\" > ${base_dir}wiski.csv
    fi
    tail -n +2 $f | tr -d '\r' | sed -e "s/$/,\"$MYDATE\"/" >> ${base_dir}wiski.csv
    count=$((count+1))
  fi
done

. ./common/finish.sh
exit 0
