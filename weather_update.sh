#!/bin/bash
HOME_PATH=$POLTERGEIST_HOME

# configuration variables - here weather_api
. $HOME_PATH/poltergeist.conf

WEATHER_URL=https://api.openweathermap.org/data/2.5/weather
WEATHER_API=$weather_api
LOG_FILE=/var/log/poltergeist/weather.log
RRDB_FILE_NAME=$HOME_PATH/weather.rrd
LAST_TIME_FILE=$HOME_PATH/weather.dat

WEATHER_DATA=$(curl -d lang=cz -d q=Michle -d APPID=$WEATHER_API -s -G $WEATHER_URL)
WEATHER_TIME=$(echo $WEATHER_DATA | jq '.dt')
[ -f $LAST_TIME_FILE ] && LAST_TIME=$(cat $LAST_TIME_FILE)

if [ "$WEATHER_TIME" != "$LAST_TIME"  ]; then
    echo $WEATHER_DATA >> $LOG_FILE
    echo $WEATHER_TIME > $LAST_TIME_FILE

    # update rrd
    RRDB_UPDATE=$(rrdtool last $RRDB_FILE_NAME)
    if [ "$WEATHER_TIME" -gt "$RRDB_UPDATE"  ]
    then
        WEATHER_TEMP=$(echo $WEATHER_DATA | jq '.main.temp')
        TEMPERATURE_C=$(python -c "print round($WEATHER_TEMP-273.15, 1)")
        HUMIDITY=$(echo $WEATHER_DATA | jq '.main.humidity')
        WIND=$(echo $WEATHER_DATA | jq '.wind.speed')

        rrdtool update $RRDB_FILE_NAME -t temp:humidity:wind $WEATHER_TIME@$TEMPERATURE_C:$HUMIDITY:$WIND
    fi
fi
