HOME_PATH=$POLTERGEIST_HOME

if [ -z $(pgrep -x receive433) ]
then
    #screen -Sdm poltergeist 
    #screen -r poltergeist -X stuff $"sudo $HOME_PATH/receive433\n"
    sudo $HOME_PATH/receive433
fi
