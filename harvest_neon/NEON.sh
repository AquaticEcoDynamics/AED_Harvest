#!/bin/bash

. ./security/neon.x

NEON_SERVER="https://restservice-neon.unidata.com.au:443/NeonRESTService.svc"

TMPPRE="/tmp/tmpx_$$_"
TOKTMP=${TMPPRE}AToken
NODTMP=${TMPPRE}NodeList
CHNTMP=${TMPPRE}ChannelList
TIME=`date +%H:%M:00`
STARTTIME=`date --date=-24hours +%F`T${TIME}
ENDTIME=`date +%F`T${TIME}
ISODATE=`date +%Y%m%d%H%M`
#ISODATE=202006121444
COUNT=0
DATADIR="data/`date +%Y`/harvest_neon"

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
     LINE=`head -1 $2`
     LINE=${LINE},$1
   else
     LINE=Time,$1
   fi
   echo $LINE > x_$2
   while read LINE ; do
     TIME=`echo $LINE | cut -f4 -d\" | tr -d '-' | tr -d ':' | tr -d 'T'`
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
     echo $LINE >> x_$2
   done
   if [ -f $2 ] ; then
     /bin/rm $2
   fi
   /bin/mv x_$2 $2
}

#------------------------------------------------------------------------------#
show_channels() {
   OUTFILE=$2
   FTCHFILE=${TMPPRE}${ChanName}
   while read LINE ; do
     COUNT=0
     ChanID=`echo $LINE | cut -f2 -d: | cut -f1 -d,`
     ChanNam=`echo $LINE | cut -f3 -d: | cut -f1 -d, | tr ' ' '_' | tr '\/' '-' | tr -d '\"'`
     echo CHANNEL $ChanID   CALLED $ChanNam

     wget -O "${FTCHFILE}" --header="X-Authentication-Token:${LoginToken}" "${NEON_SERVER}/GetData/${ChanID}?StartTime=${STARTTIME}&EndTime=${ENDTIME}" > /dev/null 2>&1

#    mkdir -p $1/${ChanNam} >/dev/null 2>&1
#    cat ${FTCHFILE} | cut -f2 -d\[ | cut -f1 -d] | sed -e 's/},{/}\n{/g' | make_csv "$1/${ChanNam}/${ISODATE}.csv"

     cat ${FTCHFILE} | cut -f2 -d\[ | cut -f1 -d] | sed -e 's/},{/}\n{/g' | append_csv ${ChanNam} "${OUTFILE}"

     COUNT=$((COUNT+1))
   done
}

#------------------------------------------------------------------------------#
show_nodes() {
   while read LINE ; do
       NodeID=`echo ${LINE} | cut -f2 -d: | cut -f1 -d,`
       NodeNam=`echo ${LINE} | cut -f3 -d: | cut -f1 -d, | tr ' ' '_' | tr -d '\"'`
       echo NodeID ${NodeID} Called ${NodeNam} has the following channels :

       wget -O ${CHNTMP} --header="X-Authentication-Token:${LoginToken}" "${NEON_SERVER}/GetChannelList/${NodeID}?ShowInactive=false" > /dev/null 1>&1

       cat ${CHNTMP} | cut -f2 -d\[ | cut -f1 -d] | sed -e 's/},{/}\n{/g' | show_channels ${NodeNam} tmpx_${NodeNam}_$$.csv
       /bin/rm ${CHNTMP}

       if [ ! -d ${DATADIR}/neon_${NodeNam} ] ; then
          mkdir -p ${DATADIR}/neon_${NodeNam}
       fi
       /bin/mv tmpx_${NodeNam}_$$.csv ${DATADIR}/neon_${NodeNam}/${ISODATE}.csv
   done
}

#------------------------------------------------------------------------------#

wget -O ${TOKTMP} "${NEON_SERVER}/GetSession?u=${USERNAME}&p=${PASSWORD}" > /dev/null 2>&1

# Extract the token from the response
LoginToken=`cat ${TOKTMP} | cut -f2 -d: | tr -d '\"' | tr -d '}' | tr -d '\\\'`
cat ${TOKTMP}
echo
echo LoginToken=\"${LoginToken}\"
/bin/rm ${TOKTMP}

#echo wget -O ${NODTMP} --header="X-Authentication-Token:${LoginToken}" "${NEON_SERVER}/GetNodeList"
wget -O ${NODTMP} --header="X-Authentication-Token:${LoginToken}" "${NEON_SERVER}/GetNodeList" > /dev/null 2>&1

cat ${NODTMP} | cut -f2 -d\[ | cut -f1 -d] | sed -e 's/},{/}\n{/g' | show_nodes
/bin/rm ${NODTMP}


#echo $STARTTIME
#echo $ENDTIME

exit 0
