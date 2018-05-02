#!/bin/bash
# Testuje soubor heating.dat a kdyz se lisi hodnota 'heating' od minule, tak
# to zaznamena v databazi a ulozi aktualni hodnotu pro pristi porovnani.
# Struktura souboru heating.dat je timestamp:value
# Timestamp je int (unix epoch) a value je 0 nebo 1 (vypnuto / zapnuto)

HOME_PATH=$POLTERGEIST_HOME

ACTUAL_DATA_FILE_NAME=$HOME_PATH/heating.dat
LAST_DATA_FILE_NAME=$HOME_PATH/heating.old
LOG_FILE=/var/log/poltergeist/heating.log

if [ ! -f $ACTUAL_DATA_FILE_NAME ]; then
    (>&2 echo "File $LAST_DATA_FILE_NAME not found!")
    exit 1
fi

if [ ! -f $LAST_DATA_FILE_NAME ]; then
    echo "File $LAST_DATA_FILE_NAME not found, creating."
    cp $ACTUAL_DATA_FILE_NAME $LAST_DATA_FILE_NAME
    exit 0
fi

# parse 1st field
DATA_TIMESTAMP=$(cut -f1 -d: $ACTUAL_DATA_FILE_NAME)

re='^[0-9]+$'
if ! [[ $DATA_TIMESTAMP =~ $re ]] ; then
   # File with timestamp is probably empty, exiting silently
   exit 0
fi

# parse 2nd field
ACTUAL_DATA=$(cut -f2 -d: $ACTUAL_DATA_FILE_NAME)
LAST_DATA=$(cut -f2 -d: $LAST_DATA_FILE_NAME)

# evaluate
if [ "$ACTUAL_DATA" != "$LAST_DATA" ]; then
    TEXT="Skript '$0': Neznámá hodnota"
    TEXT_DATE=$(date -d @$DATA_TIMESTAMP +'Topení %Y-%m-%d v %H:%M')
    (echo $ACTUAL_DATA | grep -Eq  ^0.*) && TEXT="$TEXT_DATE vypnuto"
    (echo $ACTUAL_DATA | grep -Eq  ^1.*) && TEXT="$TEXT_DATE ZAPNUTO"
    # save this change for future comparision
    cp $ACTUAL_DATA_FILE_NAME $LAST_DATA_FILE_NAME

    # log
    echo $(date +%s),$ACTUAL_DATA >>$LOG_FILE
fi
