#!/bin/bash
# Test if file 'reboot.dat' is different from last timestamp and then send email.
# Content of file 'reboot.dat' is simply timestamp.
# Timestamp is int (unix epoch).

HOME_PATH=$POLTERGEIST_HOME

ACTUAL_DATA_FILE_NAME=$HOME_PATH/reboot.dat
LAST_DATA_FILE_NAME=$HOME_PATH/reboot.old

if [ ! -f $ACTUAL_DATA_FILE_NAME ]; then
    echo "File $ACTUAL_DATA_FILE_NAME not found, creating."
    date +%s > $ACTUAL_DATA_FILE_NAME
    exit 1
fi

if [ ! -f $LAST_DATA_FILE_NAME ]; then
    echo "File $LAST_DATA_FILE_NAME not found, creating."
    cp $ACTUAL_DATA_FILE_NAME $LAST_DATA_FILE_NAME
    exit 0
fi

ACTUAL_DATA=$(cat $ACTUAL_DATA_FILE_NAME)
LAST_DATA=$(cat $LAST_DATA_FILE_NAME)

# evaluate
if [ "$ACTUAL_DATA" != "$LAST_DATA" ]; then
    REBOOT_DATE=$(date --date=@$ACTUAL_DATA +%F)
    REBOOT_TIME=$(date --date=@$ACTUAL_DATA '+%T %Z')
    SUBJECT="Raspberry Pi was rebooted on $REBOOT_DATE at $REBOOT_TIME"
    $HOME_PATH/print_info.sh >$HOME_PATH/info.txt

    cat $HOME_PATH/info.txt | mail -s"$SUBJECT" mvondr+rpi@gmail.com
    cp $ACTUAL_DATA_FILE_NAME $LAST_DATA_FILE_NAME
fi
