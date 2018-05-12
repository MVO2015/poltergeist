#!/bin/bash
# Write timestamp to file reboot.dat
# Timestamp is int (unix epoch).

HOME_PATH=$POLTERGEIST_HOME

TIMESTAMP=$(date +%s)
echo $TIMESTAMP > $HOME_PATH/reboot.dat
