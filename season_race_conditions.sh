HOME_PATH=$POLTERGEIST_HOME
SEASON_START_FILE=$HOME_PATH/season_start.dat
SEASON_END_FILE=$HOME_PATH/season_end.dat

nicedate() {
    date --date=@$1 +"%F"
}

print_summary() {
    SEASON_START=$(cat $SEASON_START_FILE)
    SEASON_END=$(cat $SEASON_END_FILE)
    if [[ $SEASON_END -gt $SEASON_START ]]
    then
        PREFIX=Heating
    else
        PREFIX="The last heating"
    fi

    if [[ $SEASON_START -gt 1 || $SEASON_END -gt 1 ]]
    then
        echo "Summary:"
        echo "-------"
    fi
    [[ $SEASON_START -gt 1 ]] && echo "Heating season started on $(nicedate $SEASON_START)."
    [[ $SEASON_END -gt 1 ]] && echo "$PREFIX season finished on $(nicedate $SEASON_END)."
}

if [[ ! -f "$SEASON_START_FILE" || ! -f "$SEASON_END_FILE" ]]
then
    echo 0 > $SEASON_START_FILE
    echo 0 > $SEASON_END_FILE
    echo "Heating season was initialized."
fi

TODAY=$(date +%s)

# Fixture
#TODAY=$(date -d"June 1" +%s)

TODAY_MONTH=$(date -d@$TODAY +%m)

FIX_DATE_START=$(date -d"september 1" +%s)
FIX_DATE_END=$(date -d"june 1" +%s)
OUT_OF_SEASON_MONTHS="06 07 08"
SEASON_START=$(cat $SEASON_START_FILE)
SEASON_END=$(cat $SEASON_END_FILE)

STATUS_RUNNING=0
[[ $SEASON_START -gt $SEASON_END ]] && STATUS_RUNNING=1

# Test start condition
if [[ $OUT_OF_SEASON_MONTHS != *$TODAY_MONTH* && $STATUS_RUNNING == 0 ]]
then
    ./start_season.sh
    print_summary
fi

# Test end condition
if [[ $OUT_OF_SEASON_MONTHS = *$TODAY_MONTH* && $STATUS_RUNNING == 1 ]]
then
    ./end_season.sh
    print_summary
fi

# Other prints
SEASON_START=$(cat $SEASON_START_FILE)
SEASON_END=$(cat $SEASON_END_FILE)
if [[ $SEASON_START -eq 0 && $SEASON_END -eq 0 ]]
then
    echo "Out of heating season. It will begin not earlier than $(nicedate $FIX_DATE_START)." 
    echo 1 > $SEASON_START_FILE
    echo 1 > $SEASON_END_FILE
fi
