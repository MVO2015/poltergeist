# create graph of the last year heating, outside temperature, humidity and wind
# and send it via email

HOME_PATH=$POLTERGEIST_HOME

LAST_YEAR=$(date -d"-1year" +%Y)
THIS_YEAR=$(($LAST_YEAR + 1))

DATE_END="$THIS_YEAR-01-01"
PERIOD=1y
GRAPH_FILE=$HOME_PATH/graphs/heating_$LAST_YEAR.png
GRAPH_TITLE="Topení za rok $LAST_YEAR"

$HOME_PATH/draw_graph.sh "$DATE_END" "$PERIOD" "$GRAPH_FILE" "$GRAPH_TITLE"

echo "" | mail -s"$GRAPH_TITLE" -A$GRAPH_FILE mvondr+rpi.heating@gmail.com
