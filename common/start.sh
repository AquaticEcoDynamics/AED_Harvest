#
# common/start.sh
#

BASENAME=`dirname $0`
BASENAME=`basename $BASENAME`

TODAY=""
SITENAME=""
DEBUG=false
while [ $# -gt 0 ] ; do
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --today)
      shift
      export TODAY="$1"
      ;;
    --site)
      shift
      export SITENAME="$1"
      ;;
    *)
      ;;
  esac
  shift
done

if [ "$SITENAME" != "" ] ; then
  BASENAME="${BASENAME}_${SITENAME}"
fi
BASENAME=`echo $BASENAME | tr ' ' '-' | tr [:upper:] [:lower:]`

LOGDIR="data/log/${BASENAME}"
TMPLOGDIR="/tmp/log_$$"
if [ ! -d "$LOGDIR" ] ; then
  mkdir -p "$LOGDIR"
fi

# echo today supplied is $TODAY

if [ "$TODAY" = "" ] ; then
  # Start with "today"
  TODAY=`date +"%Y%m%d"`
  LOGTODAY=`date +"%Y%m%d%H%M"`
else
  T1=$TODAY
  TODAY=`date --date="$TODAY" +"%Y%m%d"`
  if [ $? != 0 ] ; then
    echo cannot use supplied date \"$T1\"
    exit 1
  fi
  LOGTODAY=`date --date="$T1" +"%Y%m%d%H%M"`
fi

# echo today is $TODAY

LOGNOW=`date +"%Y%m%d%H%M"`
date +"%Y-%m-%d %H:%M" > "${LOGDIR}/last_run"

mkdir -p ${TMPLOGDIR}
if [ $? -ne 0 ] ; then
  echo failed to make tmp log dir \"$TMPLOGDIR\"
exit
fi

###== build some time related values based on "TODAY"

YEAR=`echo $TODAY | cut -c1-4`
MONTH=`echo $TODAY | cut -c5-6`
DAY=`echo $TODAY | cut -c7-8`

OUTFILE="${YEAR}${MONTH}${DAY}.csv"

YESTERDAY=`date --date="${YEAR}-${MONTH}-${DAY} -1day" +%Y%m%d`
TOMORROW=`date --date="${YEAR}-${MONTH}-${DAY} +1day" +%Y%m%d`

YYEAR=`echo $YESTERDAY | cut -c1-4`
YMONTH=`echo $YESTERDAY | cut -c5-6`
YDAY=`echo $YESTERDAY | cut -c7-8`

TYEAR=`echo $TOMORROW | cut -c1-4`
TMONTH=`echo $TOMORROW | cut -c5-6`
TDAY=`echo $TOMORROW | cut -c7-8`

# echo $YYEAR $YMONTH $YDAY
# echo $YEAR $MONTH $DAY
# echo $TYEAR $TMONTH $TDAY

ISODATE=$TODAY

# Run from yesterday to tomorrow so we get all the relevant data
START="${YYEAR}-${YMONTH}-${YDAY}"
END="${TYEAR}-${TMONTH}-${TDAY}"

###== echo start from $START to $END

MYSTART="${YYEAR}${YMONTH}${YDAY}235959"
MYEND="${YEAR}${MONTH}${DAY}235959"

###== some general utility functions ==###

to_std_time_fmt () {
  # Takes one argument a date/time in YYYYmmddHHMMSS format and produces "YYYY-mm-dd HH:MM"
  echo "`echo $1 | cut -c1-4`-`echo $1 | cut -c5-6`-`echo $1 | cut -c7-8` `echo $1 | cut -c9-10`:`echo $1 | cut -c11-12`"
}

log_last_data () {
    echo "$1" > "${TMPLOGDIR}/last_data"
}

log_last_update () {
    date +"%Y-%m-%d %H:%M" > "${TMPLOGDIR}/last_update"
}
