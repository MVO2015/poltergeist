# create graph of the last month heating, outside temperature, humidity and wind
# and send it via email

HOME_PATH=$POLTERGEIST_HOME

LAST_MONTH_NAME=$(date -d-1month +%B)

DATE_END="today -$(($(date +%d)-1)) days 0:00"
PERIOD=1m
GRAPH_FILE=$HOME_PATH/graphs/heating1w.png
GRAPH_TITLE="Topení za měsíc $LAST_MONTH_NAME"

$HOME_PATH/draw_graph.sh "$DATE_END" "$PERIOD" "$GRAPH_FILE" "$GRAPH_TITLE"

echo "" | mail -s"$GRAPH_TITLE" -A$GRAPH_FILE mvondr+rpi.heating@gmail.com
