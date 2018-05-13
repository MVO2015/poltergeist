#!/bin/bash
HOME_PATH=$POLTERGEIST_HOME

REBOOT_FILE=$HOME_PATH/reboot.old
SEASON_START_FILE=$HOME_PATH/season_start.dat
SEASON_END_FILE=$HOME_PATH/season_end.dat
HEATING_SENSOR_FILE=$HOME_PATH/heating.dat
WEATHER_LAST_UPDATE_FILE=$HOME_PATH/weather.dat
DISK_USAGE_FILE=$HOME_PATH/disk_usage.txt

IPADDRESS=$(ip address | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
if [ -f $REBOOT_FILE ] ;
then
  LAST_REBOOT_DATE=@$(cat $REBOOT_FILE)
  LAST_REBOOT=$(date -d$LAST_REBOOT_DATE +'%F %R')
else
  LAST_REBOOT="N/A"
fi

if [ -f $SEASON_START_FILE ] ;
then
  SEASON_START_DATE=@$(cat $SEASON_START_FILE)
  SEASON_START=$(date -d$SEASON_START_DATE +'%F %R')
else
  SEASON_START="N/A"
fi

if [ -f $SEASON_END_FILE ] ;
then
  SEASON_END_DATE=@$(cat $SEASON_END_FILE)
  SEASON_END=$(date -d$SEASON_END_DATE +'%F %R')
else
  SEASON_END="N/A"
fi

if [ -f $HEATING_SENSOR_FILE ] ;
then
  HEATING_SENSOR_DATE=@$(cat $HEATING_SENSOR_FILE | cut -f1 -d:)
  HEATING_SENSOR_VALUE=$(cat $HEATING_SENSOR_FILE | cut -f2 -d:)
  HEATING_SENSOR=$(date -d$HEATING_SENSOR_DATE +'%F %R')
else
  HEATING_SENSOR="N/A"
fi

if [ -f $WEATHER_LAST_UPDATE_FILE ] ;
then
  WEATHER_LAST_UPDATE_DATE=@$(cat $WEATHER_LAST_UPDATE_FILE)
  WEATHER_LAST_UPDATE=$(date -d$WEATHER_LAST_UPDATE_DATE +'%F %R')
else
  WEATHER_LAST_UPDATE="N/A"
fi
DISK_USAGE=$(df -h / >$DISK_USAGE_FILE)


[ -f $HOME_PATH/season_on.dat ] && SEASON_TEXT="Heating season is on." || SEASON_TEXT="Heating season is over."

echo "Poltergeist status information:"
echo "-------------------------------"
echo "SYSTEM:"
echo "IP address: $IPADDRESS"
echo "Home path: $HOME_PATH"
echo "Last reboot on: $LAST_REBOOT"
cat $DISK_USAGE_FILE
echo
echo "HEATING:"
echo $SEASON_TEXT
echo "Last sensor update / value: "$HEATING_SENSOR / $HEATING_SENSOR_VALUE
echo "Season start: $SEASON_START"
echo "Season end: $SEASON_END"
echo
echo "WEATHER:"
echo "Last weather update: "$WEATHER_LAST_UPDATE
