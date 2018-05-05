#!/bin/bash
# Testuje soubor heating.old
# Struktura souboru heating.old je timestamp:value
# Timestamp je int (unix epoch) a value je 0 nebo 1 (vypnuto / zapnuto)

HOME_PATH=$POLTERGEIST_HOME

DATA_FILE_NAME=$HOME_PATH/heating.old
SEASON_FILE_NAME=$HOME_PATH/season_on.dat
SEASON_END_FILE_NAME=$HOME_PATH/season_end.dat

if [ ! -f $DATA_FILE_NAME ]; then
   # File does not exist, exiting silently
    exit 1
fi

# parse 1st field
DATA_TIMESTAMP=$(cut -f1 -d: $DATA_FILE_NAME)

re='^[0-9]+$'
if ! [[ $DATA_TIMESTAMP =~ $re ]] ; then
   # File with timestamp is probably empty, exiting silently
   exit 1
fi

# parse 2nd field
DATA=$(cut -f2 -d: $DATA_FILE_NAME)

TEXT="Should be fulfilled"
ACTUAL_DATE=$(date +%s)

if [ -f $SEASON_FILE_NAME ] ; then
    TEXT_DATE=$(date -d @$DATA_TIMESTAMP +'Status: heating is from %Y-%m-%d %H:%M')
    DAYS_COUNT=$(( ($ACTUAL_DATE - $DATA_TIMESTAMP) / 86400 ))
    if [ $DAYS_COUNT -gt 0  ]
    then
         LENGTH="$DAYS_COUNT days"
    else
        LENGTH=$(date -d"0 $ACTUAL_DATE seconds - $DATA_TIMESTAMP seconds" +'%H:%M hours')
    fi
    LENGTH="(for $LENGTH)"
    (echo $DATA | grep -Eq  ^0.*) && TEXT="$TEXT_DATE off $LENGTH"
    (echo $DATA | grep -Eq  ^1.*) && TEXT="$TEXT_DATE ON LENGTH"
else
    SEASON_END=$(cat $SEASON_END_FILE_NAME)
    TEXT=$(date -d @$SEASON_END +'Poltergeist: season finished on %Y-%m-%d.')
fi

# send email
$HOME_PATH/print_info.sh | mail -s"$TEXT" mvondr+rpi.heating@gmail.com
