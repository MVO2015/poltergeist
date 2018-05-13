# create graph of the last month heating, outside temperature, humidity and wind
# and send it by email

HOME_PATH=$POLTERGEIST_HOME
GRAPH_FILE=$HOME_PATH/graphs/heating1m.png

LAST_MONTH_NAME=$(date -d-1day +%B)

DATE_END="today -$(($(date +%d)-1)) days 0:00"
PERIOD=1m
GRAPH_TITLE="Heating for month $LAST_MONTH_NAME"

$HOME_PATH/draw_graph.sh "$DATE_END" "$PERIOD" "$GRAPH_FILE" "$GRAPH_TITLE"

echo "" | mail -s"$GRAPH_TITLE" -A$GRAPH_FILE mvondr+rpi.heating@gmail.com
