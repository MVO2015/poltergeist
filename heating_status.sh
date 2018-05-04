#!/bin/bash
# Testuje soubor heating.old
# Struktura souboru heating.old je timestamp:value
# Timestamp je int (unix epoch) a value je 0 nebo 1 (vypnuto / zapnuto)

HOME_PATH=$POLTERGEIST_HOME

DATA_FILE_NAME=$HOME_PATH/heating.old

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
TEXT_DATE=$(date -d @$DATA_TIMESTAMP +'Status: topení je od %Y-%m-%d %H:%M')
ACTUAL_DATE=$(date +%s)
DAYS_COUNT=$(( ($ACTUAL_DATE - $DATA_TIMESTAMP) / 86400 ))
if [ $DAYS_COUNT -gt 0  ]
then
    LENGTH="$DAYS_COUNT dní"
else
    LENGTH=$(date -d"0 $ACTUAL_DATE seconds - $DATA_TIMESTAMP seconds" +'%H:%M hodin')
fi
LENGTH="($LENGTH)"
(echo $DATA | grep -Eq  ^0.*) && TEXT="$TEXT_DATE vypnuto $LENGTH"
(echo $DATA | grep -Eq  ^1.*) && TEXT="$TEXT_DATE ZAPNUTO $LENGTH"

# send email
$HOME_PATH/print_info.sh | mail -s"$TEXT" mvondr+rpi.heating@gmail.com
