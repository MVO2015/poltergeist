#!/bin/bash
# Zapise timestamp do souboru reboot.dat
# Timestamp je int (unix epoch).

HOME_PATH=$POLTERGEIST_HOME

TIMESTAMP=$(date +%s)
echo $TIMESTAMP > $HOME_PATH/reboot.dat
