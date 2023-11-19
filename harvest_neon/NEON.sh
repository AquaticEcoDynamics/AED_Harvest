#!/bin/bash

. ./security/neon.x
. ./common/start.sh

NEON_SERVER="https://restservice-neon.unidata.com.au:443/NeonRESTService.svc"

TMPPRE="/tmp/tmpx$$_"
TOKTMP=${TMPPRE}AToken
NODTMP=${TMPPRE}NodeList
CHNTMP=${TMPPRE}ChannelList

TIME=`date +%H:%M:00`
#STARTTIME=`date --date=-24hours +%F`T${TIME}
ENDTIME=`date +%F`T${TIME}
STARTTIME=`date --date=${YYEAR}-${YMONTH}-${YDAY} +%F`T00:00:00
#ENDTIME=`date --date=${TYEAR}-${TMONTH}-${TDAY} +%F`T:00:00:00
#ISODATE=`date +%Y%m%d`
COUNT=0
DATADIR="data/${YEAR}/harvest_neon"
#echo STARTTIME \"$STARTTIME\" ENDTIME \"$ENDTIME\"

#------------------------------------------------------------------------------#
make_csv() {
   echo Time,Value > $1
   while read LINE ; do
     echo $LINE | tr -d '{' | tr -d '}' | sed -e 's/"Time":"//' | sed -e 's/"Value":"//' | tr -d '"' >> $1
   done
}

#------------------------------------------------------------------------------#
append_csv() {
   if [ -f $2 ] ; then
     HEAD=`head -1 $2`
     HEAD=${HEAD},$1
   else
     HEAD=Time,$1
   fi

   while read LINE ; do
     TIME=`echo $LINE | cut -f4 -d\" | tr -d '-' | tr -d ':' | tr -d 'T'`
     LTIME=`echo $LINE | cut -f4 -d\" | tr -d ' ' | cut -f1 -dT`
#echo time \"$TIME\" ltime \"$LTIME\"

     VALU=`echo $LINE | cut -f8 -d\"`
#    echo $TIME $VALU
     if [ -f $2 ] ; then
       LINE=`grep $TIME $2`
     else
       LINE=""
     fi
     if [ "$LINE" = "" ] ; then
       LINE=$TIME
       TC=0
       while [ $TC -lt $COUNT ] ; do
          LINE=${LINE},
          TC=$((TC+1))
       done
     fi
     LINE=${LINE},$VALU
     if [ ! -f x_$2 ] ; then
       echo $HEAD > x_$2
     fi
     echo $LINE >> x_$2
     set_data_date "$LTIME"
   done
   if [ -f x_$2 ] ; then
     if [ -f $2 ] ; then
       /bin/rm $2
     fi
     /bin/mv x_$2 $2
     log_last_update
   fi
}

#------------------------------------------------------------------------------#
show_channels() {
   OUTFILE=$2
   while read LINE ; do
     COUNT=0
#echo $LINE
  #   CLEANED=`echo $LINE | tr -d '"' | tr -d '{' | tr -d '}'`
  #   ChanID=`echo $CLEANED | tr ',' '\n' | grep -w 'ID' | cut -f2 -d:`
  #   ChanNam=`echo $CLEANED | tr ',' '\n' | grep -w 'Name' | cut -f2 -d: | tr ' ' '_' | tr '\/' '-'`
  #   FirstTime=`echo $CLEANED | tr ',' '\n' | grep 'FirstTime' | cut -f2 -d:`
  #   LastTime=`echo $CLEANED | tr ',' '\n' | grep 'LastTime' | cut -f2 -d:`
     ChanID=`echo $LINE | cut -f2 -d: | cut -f1 -d,`
     ChanNam=`echo $LINE | cut -f3 -d: | cut -f1 -d, | tr ' ' '_' | tr '\/' '-' | tr -d '\"'`

## It's probably worth checking FirstTime and LastTime against the requested times
## also, for now at least, it seems if the sensor has stopped working (ie LastTime is a while ago) 
## it doesnt respond, even to requests for historical data.

     echo CHANNEL $ChanID   CALLED \"$ChanNam\" # FirstTime $FirstTime LastTime $LastTime

     FTCHFILE=${TMPPRE}${ChanID}

#echo "wget -q -O \"${FTCHFILE}\" --header=\"X-Authentication-Token:${LoginToken}\" \"${NEON_SERVER}/GetData/${ChanID}?StartTime=${STARTTIME}&EndTime=${ENDTIME}\""

     wget -q -O "${FTCHFILE}" --header="X-Authentication-Token:${LoginToken}" "${NEON_SERVER}/GetData/${ChanID}?StartTime=${STARTTIME}&EndTime=${ENDTIME}"

     if [ $? -eq 0 ] ; then
       cat "${FTCHFILE}" | cut -f2 -d\[ | cut -f1 -d] | sed -e 's/},{/}\n{/g' | append_csv "${ChanNam}" "${OUTFILE}"
     else
       echo failed to fetch \( $? \)
     fi

     if [ -f "${FTCHFILE}" ] ; then
       /bin/rm "${FTCHFILE}"
     fi

     COUNT=$((COUNT+1))
   done
}

#------------------------------------------------------------------------------#
show_nodes() {
   while read LINE ; do
       NodeID=`echo ${LINE} | cut -f2 -d: | cut -f1 -d,`
       NodeNam=`echo ${LINE} | cut -f3 -d: | cut -f1 -d, | tr ' ' '_' | tr -d '\"'`
       echo NodeID ${NodeID} Called ${NodeNam} has the following channels :

# echo  "wget -q -O ${CHNTMP} --header=\"X-Authentication-Token:${LoginToken}\" \"${NEON_SERVER}/GetChannelList/${NodeID}?ShowInactive=false\""
       wget -q -O ${CHNTMP} --header="X-Authentication-Token:${LoginToken}" "${NEON_SERVER}/GetChannelList/${NodeID}?ShowInactive=false"

       if [ $? -eq 0 ] ; then
         cat ${CHNTMP} | cut -f2 -d\[ | cut -f1 -d] | sed -e 's/},{/}\n{/g' | show_channels ${NodeNam} tmpx_${NodeNam}_$$.csv
         /bin/rm ${CHNTMP}
       else
         echo failed to get channel list for node ${NodeNam}
       fi

       if [ -f tmpx_${NodeNam}_$$.csv ] ; then
         if [ ! -d ${DATADIR}/neon_${NodeNam} ] ; then
           mkdir -p ${DATADIR}/neon_${NodeNam}
         fi
         /bin/mv tmpx_${NodeNam}_$$.csv ${DATADIR}/neon_${NodeNam}/${ISODATE}.csv
       fi
   done
}

#------------------------------------------------------------------------------#

wget -q -O ${TOKTMP} "${NEON_SERVER}/GetSession?u=${USERNAME}&p=${PASSWORD}" > /dev/null 2>&1

# Extract the token from the response
LoginToken=`cat ${TOKTMP} | cut -f2 -d: | tr -d '\"' | tr -d '}' | tr -d '\\\'`
#cat ${TOKTMP}
#echo
#echo LoginToken=\"${LoginToken}\"
/bin/rm ${TOKTMP}

#echo wget -q -O ${NODTMP} --header="X-Authentication-Token:${LoginToken}" "${NEON_SERVER}/GetNodeList"
wget -q -O ${NODTMP} --header="X-Authentication-Token:${LoginToken}" "${NEON_SERVER}/GetNodeList"

cat ${NODTMP} | cut -f2 -d\[ | cut -f1 -d] | sed -e 's/},{/}\n{/g' | show_nodes
/bin/rm ${NODTMP}

. ./common/finish.sh

exit 0
