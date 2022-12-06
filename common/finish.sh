#
# common/finish.sh
#

if [ $LOGTODAY -eq $LOGNOW ] ; then
  # this is not a special backfill run
  if [ -f "${TMPLOGDIR}/last_update" ] ; then
    /bin/cp "${TMPLOGDIR}/last_update" "${LOGDIR}/last_update"
  fi
  if [ -f "${TMPLOGDIR}/last_data" ] ; then
    /bin/cp "${TMPLOGDIR}/last_data" "${LOGDIR}/last_data"
  fi
fi
if [ -d "${TMPLOGDIR}" ] ; then
  /bin/rm -rf "${TMPLOGDIR}"
fi
