#
# common/finish.sh
#

if [ -d "${TMPLOGDIR}" ] ; then
  if [ $LOGTODAY -eq $LOGNOW ] ; then
    # this is not a special backfill run
    if [ -f "${TMPLOGDIR}/last_update" ] ; then
      NOWLU=`cat ${TMPLOGDIR}/last_update |  cut -f1 -d\  | tr -d '-'`
      CURLU=`cat ${LOGDIR}/last_update |  cut -f1 -d\  | tr -d '-'`
      if [ $CURLU -lt $NOWLU ] ; then
        /bin/cp "${TMPLOGDIR}/last_update" "${LOGDIR}/last_update"
      fi
    fi
  fi

  if [ -f "${TMPLOGDIR}/last_data" ] ; then
    NOWLD=`cat ${TMPLOGDIR}/last_data |  cut -f1 -d\  | tr -d '-'`
    if [ -f ${LOGDIR}/last_data ] ; then
      CURLD=`cat ${LOGDIR}/last_data |  cut -f1 -d\  | tr -d '-'`
    else
      CURLD=""
    fi
    if [ "$CURLD" = "" ] ; then
      /bin/cp "${TMPLOGDIR}/last_data" "${LOGDIR}/last_data"
    elif [ $CURLD -lt $NOWLD ] ; then
      /bin/cp "${TMPLOGDIR}/last_data" "${LOGDIR}/last_data"
    fi
  fi

  if [ -f "${TMPLOGDIR}/start_data" ] ; then
    NOWSD=`cat ${TMPLOGDIR}/start_data |  cut -f1 -d\  | tr -d '-'`
    if [ -f ${LOGDIR}/start_data ] ; then
      CURSD=`cat ${LOGDIR}/start_data |  cut -f1 -d\  | tr -d '-'`
    else
      CURSD=""
    fi
    if [ "$CURSD" = "" ] ; then
      /bin/cp "${TMPLOGDIR}/start_data" "${LOGDIR}/start_data"
    elif [ $CURSD -gt $NOWSD ] ; then
      /bin/cp "${TMPLOGDIR}/start_data" "${LOGDIR}/start_data"
    fi
  fi

  /bin/rm -rf "${TMPLOGDIR}"
fi
