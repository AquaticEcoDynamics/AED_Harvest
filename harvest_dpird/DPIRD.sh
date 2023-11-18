#!/bin/bash

. ./security/dpird.x
. ./common/start.sh

#export DEBUG=true

FILE=/tmp/tmpx_$$.json

OUTFILE=""
DATE=""
TIME=""
DATADIR="data/${YEAR}/harvest_dpird"
mkdir -p $DATADIR >& /dev/null

HOST="https://api.dpird.wa.gov.au/"

#------------------------------------------------------------------------------#
read_until() {
   while read line ; do
      if [ "$line" != "" ] ; then
        if [ "$line" = "$1" ] ; then
          echo $line
          return
        fi
      fi
   done
   echo ""
}
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
extract_entry () {
   read line  # should be '{'

   # "airTemperature"
   read line  # should be '"airTemperature":'
   read line  # should be '{'

   read AIRTEMP # should be like :
   # "min":18,"minTime":"2016-11-30T23:03:00Z","max":20.2,"maxTime":"2016-12-01T00:00:00Z","avg":19.1
   ATMIN=`echo $AIRTEMP | cut -f2 -d\: | cut -f1 -d,`
   ATMAX=`echo $AIRTEMP | cut -f6 -d\: | cut -f1 -d,`
   ATAVG=`echo $AIRTEMP | cut -f10 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo airTemperature.min = $ATMIN
   echo airTemperature.max = $ATMAX
   echo airTemperature.avg = $ATAVG
fi
   read line  # should be '}'

   # "relativeHumidity"
   read line  # should be ',"relativeHumidity":'
if [ "$DEBUG" = "true" ] ; then
echo RELHUM $line
fi
   read line  # should be '{'

   read RELHUM # should be like :
   # "min":58.1,"minTime":"2016-12-01T00:00:00Z","max":63.2,"maxTime":"2016-11-30T23:04:00Z","avg":60.5
   RLMIN=`echo $RELHUM | cut -f2 -d\: | cut -f1 -d,`
   RLMAX=`echo $RELHUM | cut -f6 -d\: | cut -f1 -d,`
   RLAVG=`echo $RELHUM | cut -f10 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo relativeHumidity.min = $RLMIN
   echo relativeHumidity.max = $RLMAX
   echo relativeHumidity.avg = $RLAVG
fi
   read line  # should be '}'

   # "dewPoint"
   read line  # should be ',"dewPoint":'
if [ "$DEBUG" = "true" ] ; then
echo DEWPOINT $line
fi
   read line  # should be '{'

   read DEWPOINT # should be like :
   # "min":10.9,"max":11.7,"avg":11.2
   DWMIN=`echo $DEWPOINT | cut -f2 -d\: | cut -f1 -d,`
   DWMAX=`echo $DEWPOINT | cut -f3 -d\: | cut -f1 -d,`
   DWAVG=`echo $DEWPOINT | cut -f4 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo dewPoint.min = $DWMIN
   echo dewPoint.max = $DWMAX
   echo dewPoint.avg = $DWAVG
fi
   read line  # should be '}'

   # "evapotranspiration"
   read line  # should be ',"evapotranspiration":'
if [ "$DEBUG" = "true" ] ; then
echo EVAPO $line
fi
   read line  # should be '{'

   read EVAPTRS # should be like :
   # "shortCrop":0.24,"tallCrop":0.27
   EVSHRT=`echo $EVAPTRS | cut -f2 -d\: | cut -f1 -d,`
   EVTALL=`echo $EVAPTRS | cut -f3 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo evapotranspiration.shortCrop = $EVSHRT
   echo evapotranspiration.tallCrop = $EVTALL
fi
   read line  # should be '}'

   # "solarExposure"
   read SOLAR  # should be ',"solarExposure":<value>,"rainfall":<value>,"soilTemperature":'
               # ,"solarExposure":1308.6,"rainfall":0,"soilTemperature":
if [ "$DEBUG" = "true" ] ; then
echo SOLAR $SOLAR
fi
   SOLARTOT=`echo $SOLAR | cut -f2 -d\: | cut -f1 -d,`
   RAINFALL=`echo $SOLAR | cut -f3 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo solarExposure.solarExposure = $SOLARTOT
   echo solarExposure.rainfall = $RAINFALL
fi

   SOILTMP=`echo $SOLAR | cut -f4 -d\: | cut -f1 -d,`
   if [ "$SOILTMP" = "" ] ; then
      read line  # should be '{'

      read SOILTMP # should be like :
if [ "$DEBUG" = "true" ] ; then
echo SOILTEMP $SOILTMP
fi
      # "min":24.3,"max":24.7,"avg":24.5
      SLMIN=`echo $SOILTMP | cut -f2 -d\: | cut -f1 -d,`
      SLMAX=`echo $SOILTMP | cut -f3 -d\: | cut -f1 -d,`
      SLAVG=`echo $SOILTMP | cut -f4 -d\: | cut -f1 -d,`

      read line  # should be '}'
      # "deltaT"
      read line  # should be ',"deltaT":'
   else
      SLMIN=""
      SLMAX=""
      SLAVG=""
   fi
if [ "$DEBUG" = "true" ] ; then
   echo soilTemperature.min = $SLMIN
   echo soilTemperature.max = $SLMAX
   echo soilTemperature.avg = $SLAVG
fi
   read line  # should be '{'

   read DELTAT # should be like :
       # "min":3.6,"max":4.5,"avg":4.1
   DLMIN=`echo $DELTAT | cut -f2 -d\: | cut -f1 -d,`
   DLMAX=`echo $DELTAT | cut -f3 -d\: | cut -f1 -d,`
   DLAVG=`echo $DELTAT | cut -f4 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo deltaT.min = $DLMIN
   echo deltaT.max = $DLMAX
   echo deltaT.avg = $DLAVG
fi
   read line  # should be '}'

   # "wetBulb"
   read line  # should be ',"wetBulb":'
if [ "$DEBUG" = "true" ] ; then
echo WETBULD $line
fi
   read line  # should be '{'

   read WETBULB # should be like :
   # "max":15.7,"avg":15
   WBMAX=`echo $WETBULB | cut -f2 -d\: | cut -f1 -d,`
   WBAVG=`echo $WETBULB | cut -f3 -d\:`
if [ "$DEBUG" = "true" ] ; then
   echo wetBulb.max = $WBMAX
   echo wetBulb.avg = $WBAVG
fi
   read line  # should be '}'


   # "wind"
   read line  # should be ',"wind":['
if [ "$DEBUG" = "true" ] ; then
  echo WIND LINE $line
fi
   read line  # should be '{'

   # ,"wind":[
   # {
   # "height":3,"avg":
   # {
   # "speed":4.24,"direction":
   # {
   # "degrees":158,"compassPoint":"SSE"
   # }
   # 
   # }
   # ,"max":
   # {
   # "speed":10.84,"time":"2016-11-30T23:02:00Z","direction":
   # {
   # "degrees":139,"compassPoint":"SE"
   # }
   # 
   # }
   # 
   # }
   # ]
   read line
      # "height":3,"avg":
   WHEIGHT=`echo $line | cut -f2 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo wind.height = $WHEIGHT
fi

   read line  # should be '{'
   read line
   # "speed":4.24,"direction":
   WSPAVG=`echo $line | cut -f2 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo wind.avg.speed = $WSPAVG
fi

   read line  # should be '{'
   read line
   # "degrees":158,"compassPoint":"SSE"
   WSPADIR=`echo $line | cut -f2 -d\: | cut -f1 -d,`
   WSPACMP=`echo $line | cut -f3 -d\:`
if [ "$DEBUG" = "true" ] ; then
   echo wind.max.dir = $WSPDIR
   echo wind.max.compass = $WSPCMP
fi
   read line  # should be '}'
   read line  # should be empty
   read line  # should be '}'

   read line  # should be ',"max""'
   read line  # should be '{'
   read line
   # "speed":10.84,"time":"2016-11-30T23:02:00Z","direction":
   WSPMAX=`echo $line | cut -f2 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo wind.max.speed = $WSPMAX
fi
   read line  # should be '{'
   read line
   # "degrees":139,"compassPoint":"SE"
   WSPMDIR=`echo $line | cut -f2 -d\: | cut -f1 -d,`
if [ "$DEBUG" = "true" ] ; then
   echo wind.max.dir = $WSPMDIR
fi
   WSPMCMP=`echo $line | cut -f3 -d\:`
if [ "$DEBUG" = "true" ] ; then
   echo wind.max.compass = $WSPMCMP
fi
   read line  # should be '}'

   read line  # should be empty
   read line  # should be '}'
   read line  # should be empty
   read line  # should be '}'
   read line  # should be ']'
   read line  # should be '}'

echo -n "$DATE $TIME,$STATION,"             >> ${OUTFILE}
echo -n "$ATMIN,$ATMAX,$ATAVG,"             >> ${OUTFILE}
echo -n "$RLMIN,$RLMAX,$RLAVG,"             >> ${OUTFILE}
echo -n "$SOLARTOT,"                        >> ${OUTFILE}
echo -n "$WHEIGHT,$WSPMAX,$WSPMDIR," >> ${OUTFILE}
echo    "$WSPAVG,$WSPADIR"         >> ${OUTFILE}
   set_data_date "$DATE $TIME"

   log_last_update

}
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
extract_data () {
   count=0
   TIME="$count:00"

   LINE=`read_until ',"data":'`
   if [ "$LINE" = "" ] ; then
     exit 1
   fi

   read line  # should be '{'
   read line  # should be '"summaries":['

   extract_entry

   while read line ; do
      count=$((count+1))
      TIME="$count:00"
      if [ "$line" = "," ] ; then
         extract_entry
      else
#        echo finished :line = \"$line\"
         return # finished
      fi
   done
}
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
get_data() {

   STATION=${1}
   DATE=${2}-${3}-${4}

   STARTTIME=`date --date=${2}-${3}-${4} +%F`T01:00Z
   ENDTIME=`date --date=${2}-${3}-${4}+1day +%F`T00:00Z
if [ "$DEBUG" = "true" ] ; then
   echo start $STARTTIME
   echo end   $ENDTIME
fi

   OUTFILE="dpird_${1}_daily_${2}${3}${4}.csv"

# URL="https://api.dpird.wa.gov.au/"
# URL="{$URL}v2/weather/stations/${STATION}/summaries/hourly"
# URL="${URL}?startDateTime=${STARTTIME}%3A00%3A00Z"
# URL="${URL}&endDateTime=${ENDTIME}%3A00%3A00Z"
# URL="${URL}&offset=0"
# URL="${URL}&limit=25"
# URL="${URL}&select="
# URL="${URL}airTemperature,airTemperatureAvg,airTemperatureMax,airTemperatureMin"
# URL="${URL},deltaTAvg,deltaTMax,deltaTMin"
# URL="${URL},dewPointAvg,dewPointMax,dewPointMin"
# URL="${URL},etoShortCrop,etoTallCrop,rainfall"
# URL="${URL},relativeHumidity,relativeHumidityAvg,relativeHumidityMax,relativeHumidityMin"
# URL="${URL},soilTemperatureAvg,soilTemperatureMax,soilTemperatureMin"
# URL="${URL},solarExposure"
# URL="${URL},wetBulbAvg,wetBulbMax"
# URL="${URL},wind,windAvgSpeed,windMaxSpeed"
# CURLCMD="curl -X GET ${URL} -H accept:application/json -H API-KEY:${APIKEY} -s -o ${FILE}"

if [ "$DEBUG" = "true" ] ; then
   echo "Curling ${STARTTIME} - ${ENDTIME}"
fi

   CURLCMD="curl -X GET ${HOST}v2/weather/stations/${STATION}/summaries/hourly?startDateTime=${STARTTIME}&endDateTime=${ENDTIME}&offset=0&limit=25&select=airTemperature,airTemperatureAvg,airTemperatureMax,airTemperatureMin,deltaTAvg,deltaTMax,deltaTMin,dewPointAvg,dewPointMax,dewPointMin,etoShortCrop,etoTallCrop,rainfall,relativeHumidity,relativeHumidityAvg,relativeHumidityMax,relativeHumidityMin,soilTemperatureAvg,soilTemperatureMax,soilTemperatureMin,solarExposure,wetBulbAvg,wetBulbMax,wind,windAvgSpeed,windMaxSpeed -H accept:application/json -H API-KEY:${APIKEY} -s -o ${FILE}"
if [ "$DEBUG" = "true" ] ; then
   echo ${CURLCMD}
fi
   ${CURLCMD}

   if [ -f ${FILE} ] ; then

if [ "$DEBUG" = "true" ] ; then
     echo "All curly"
fi

     # The header should be like (only 1 line though) :
     # station_id,record_datetime,air_temp_min,air_temp_max,air_temp_avg_degC,
     #                            hum_min,hum_max,rel_hum_avg%,rain_mm,
     #                            dewpoint_min,dewpoint_max,dewpoint_ave,
     #                            evaporation,eto_std,eto_tall,total_solar,
     #                            soil_temp_min,soil_temp_max,soil_temp_ave,
     #                            wind_speed_max,wind_speed_ave_Km_h,wind_direction_max_deg,wind_direction_max_comp,
     #                            wet_bulb_degc_min,wet_bulb_degc_max,wet_bulb_degc_ave,
     #                            delta_t_degc_min,delta_t_degc_max,delta_t_degc_ave,number_recordings

     echo "datetime,station,air_temp_min (C),air_temp_max (C),air_temp_avg (C),rel_hum_min (%),rel_hum_max (%),rel_hum_ave (%),solrad (W/m2),wind_height (m),wind_speed_max (km/h),wind_direction_max (deg),wind_speed_avg  (km/h),wind_direction_avg (deg)" > ${OUTFILE}

     sed -e 's/{/\n{\n/g' -e 's/}/\n}\n/g' < ${FILE} | extract_data

if [ "$DEBUG" != "true" ] ; then
     /bin/rm ${FILE}
fi
   fi
}
#------------------------------------------------------------------------------#

T1=`date +"%Y%m%d"`
if [ "$T1" = "$TODAY" ] ; then
  START=`date --date="${TODAY} -1day" +%Y/%m/%d`
else
  START=`date --date="${TODAY}" +%Y/%m/%d`
fi
year=`echo $START | cut -f1 -d/`
month=`echo $START | cut -f2 -d/`
day=`echo $START | cut -f3 -d/`

  OUTFILE="dpird_SP_daily_${year}${month}${day}.csv"
  get_data SP $year $month $day
  if [ -f ${OUTFILE} ] ; then
     if [ -f ${DATADIR}/${year}${month}${day}.csv ] ; then
       diff -q ${OUTFILE} ${DATADIR}/${year}${month}${day}.csv >& /dev/null
       if [ $? -eq 0 ] ; then # files are the same
         /bin/rm ${OUTFILE}
       else
         /bin/mv ${OUTFILE} ${DATADIR}/${year}${month}${day}.csv
       fi
     else
       /bin/mv ${OUTFILE} ${DATADIR}/${year}${month}${day}.csv
     fi
  fi

. ./common/finish.sh

exit 0
