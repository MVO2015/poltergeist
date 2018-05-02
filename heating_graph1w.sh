# create graph of the last week heating, outside temperature, humidity and wind 
# and send it via email

HOME_PATH=$POLTERGEIST_HOME

DATE_END="last Sunday +1 day"
PERIOD=1w
GRAPH_FILE=$HOME_PATH/graphs/heating1w.png
GRAPH_TITLE="Topení za poslední týden"

$HOME_PATH/draw_graph.sh "$DATE_END" "$PERIOD" "$GRAPH_FILE" "$GRAPH_TITLE"

echo "" | mail -s"$GRAPH_TITLE" -A$GRAPH_FILE mvondr+rpi.heating@gmail.com
