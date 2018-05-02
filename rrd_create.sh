#!/bin/bash
HEATING_FILE=heating.rrd
WEATHER_FILE=weather.rrd

if [ -f "$HEATING_FILE" ]
then
  echo "File '$HEATING_FILE' found, skipping installation."
else
  rrdtool create heating.rrd \
  --step 60 \
  DS:heating:GAUGE:120:0:1 \
  RRA:AVERAGE:0.5:1:1440 \
  RRA:AVERAGE:0.5:60:168 \
  RRA:AVERAGE:0.5:1440:365 \
  RRA:AVERAGE:0.5:525600:100
fi

if [ -f "$WEATHER_FILE" ]
then
  echo "File '$WEATHER_FILE' found, skipping installation."
else
rrdtool create weather.rrd \
--step 1800 \
--start 0 \
DS:temp:GAUGE:3600:-40:60 \
DS:humidity:GAUGE:3600:0:100 \
DS:wind:GAUGE:3600:0:200 \
RRA:AVERAGE:0.5:1:48 \
RRA:AVERAGE:0.5:2:336 \
RRA:AVERAGE:0.5:1488:12 \
RRA:AVERAGE:0.5:17520:100
fi
