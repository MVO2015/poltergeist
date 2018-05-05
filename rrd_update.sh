#!/bin/bash

HOME_PATH=$POLTERGEIST_HOME

DB_FILE_NAME=$HOME_PATH/heating.rrd
HEATING_STATUS_FILE_NAME=$HOME_PATH/heating.dat
SEASON_FILE_NAME=$HOME_PATH/season_on.dat

DB_UPDATE=$(rrdtool last $DB_FILE_NAME)
HEATING_STATUS_UPDATE=$(cut -f1 -d: $HEATING_STATUS_FILE_NAME)

NOW=$(date +'s')

re='^[0-9]+$'
if ! [[ $HEATING_STATUS_UPDATE =~ $re ]] ; then
    # File with timestamp is probably empty, exiting silently
    exit 0
fi

[ "$HEATING_STATUS_UPDATE" -gt "$DB_UPDATE"  ] && rrdtool update $DB_FILE_NAME -theating $(cat $HEATING_STATUS_FILE_NAME)
