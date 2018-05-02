# create graph of heating, outside temperature and humifity

HOME_PATH=$POLTERGEIST_HOME

# input parameters
DATE_END=$1
GRAPH_PERIOD=$2
GRAPH_FILE=$3
GRAPH_TITLE=$4

WEATHER_FILE=$HOME_PATH/weather.rrd
HEATING_FILE=$HOME_PATH/heating.rrd
TEMP_SHIFT=20
TEMP_COEF=0.5
# calculate TEMP_SHIFT / TEMP_COEF =
T_SHIFT_DIV_COEF=40

GRAPH_END=$(date --date="$DATE_END" +%s)

rrdtool graph \
    $GRAPH_FILE -aPNG -w400 -h250 \
    -e $GRAPH_END -s end-$GRAPH_PERIOD \
    --right-axis $TEMP_COEF:-$TEMP_SHIFT \
    DEF:h=$HEATING_FILE:heating:AVERAGE \
    DEF:tout=$WEATHER_FILE:temp:AVERAGE \
    DEF:humidity=$WEATHER_FILE:humidity:AVERAGE \
    DEF:wind=$WEATHER_FILE:wind:AVERAGE \
    CDEF:h100=h,100,* \
    CDEF:zero=tout,0,*,$T_SHIFT_DIV_COEF,+ \
    CDEF:tright=tout,$TEMP_COEF,/,$T_SHIFT_DIV_COEF,+ \
    CDEF:windkmh=wind,3.6,* \
    LINE:zero#00AAAA \
    AREA:h100#DD4444:"Topení [%]" \
    LINE2:humidity#AA00AA:"Venkovní vlhkost [%]" \
    LINE2:tright#0044FF:"Venkovní teplota [°C]" \
    LINE2:windkmh#FFAA00:"Vítr [km/h]" \
    --title="$GRAPH_TITLE" \
    >/dev/null
