#!/bin/bash
# Set heating season as starteded
HOME_PATH=$POLTERGEIST_HOME
SEASON_START_FILE=$HOME_PATH/season_start.dat

date +%s > $SEASON_START_FILE
echo "Heating season was started."
touch $HOME_PATH/season_on.dat
