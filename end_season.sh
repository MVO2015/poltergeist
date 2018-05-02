#!/bin/bash
# Set heating season as finished
HOME_PATH=$POLTERGEIST_HOME
SEASON_START_FILE=$HOME_PATH/season_start.dat
SEASON_END_FILE=$HOME_PATH/season_end.dat
SEASON_START=$(cat $SEASON_START_FILE)
SEASON_END=$(cat $SEASON_END_FILE)

date +%s > $SEASON_END_FILE
echo "Heating season was finished."
rm -f $HOME_PATH/season_on.dat

SEASON_PERIOD=$(echo "( `date -d@$SEASON_END +'%s'` - `date -d@$SEASON_START +'%s'`) / (24*3600)" | bc | awk '{print $1"d"}')

# create graph of the last month heating, outside temperature, humidity and wind
# and send it via email

GRAPH_FILE=$HOME_PATH/graphs/heating_season.png
GRAPH_TITLE=$(echo "Topení za sezónu `date -d@$SEASON_START +'%F'` - `date -d@$SEASON_END +'%F'`")

echo $SEASON_END
echo $SEASON_PERIOD
echo $GRAPH_FILE
echo $GRAPH_TITLE

$HOME_PATH/draw_graph.sh "@$SEASON_END" "$SEASON_PERIOD" "$GRAPH_FILE" "$GRAPH_TITLE"

echo "" | mail -s"$GRAPH_TITLE" -A$GRAPH_FILE mvondr+rpi.heating@gmail.com
