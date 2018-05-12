# create graph of yesterday heating / weather, outside temperature and humidity
# and send it by email

HOME_PATH=$POLTERGEIST_HOME
GRAPH_FILE=$HOME_PATH/graphs/heating24.png
SEASON_FILE=$HOME_PATH/season_on.dat

DATE_END="today 00:00"
PERIOD=1d

if [ -f $SEASON_FILE ] ; then
  GRAPH_TITLE_PREFIX=Weather
else
  GRAPH_TITLE_PREFIX=Heating
fi

GRAPH_TITLE="$GRAPH_TITLE_PREFIX for last 24 hours"
$HOME_PATH/draw_graph.sh "$DATE_END" "$PERIOD" "$GRAPH_FILE" "$GRAPH_TITLE"
echo "" | mail -s"$GRAPH_TITLE" -A$GRAPH_FILE mvondr+rpi.heating@gmail.com
