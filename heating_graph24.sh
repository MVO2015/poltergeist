# create graph of yesterday heating, outside temperature and humifity
# and send it by email

HOME_PATH=$POLTERGEIST_HOME

DATE_END="today 00:00"
PERIOD=1d
GRAPH_FILE=$HOME_PATH/graphs/heating24.png
GRAPH_TITLE="Topení za posledních 24h"

$HOME_PATH/draw_graph.sh "$DATE_END" "$PERIOD" "$GRAPH_FILE" "$GRAPH_TITLE"

echo "" | mail -s"$GRAPH_TITLE" -A$GRAPH_FILE mvondr+rpi.heating@gmail.com
