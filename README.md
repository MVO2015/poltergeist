# Poltergeist
Home Heating Control Center  
_on your Raspberry Pi 3 model B_

## Installation

Work on poltergeist in your project directory:
```bash
$ cd your_project_directory/poltergeist
```

create configuration file _'poltergeist.conf'_:
```bash
$ cat <<EOF >poltergeist.conf
#!/bin/bash
ssmtp_AuthUser=your email address, eg. you@yourdomain.com
ssmtp_AuthPass=your smtp password, e.g. xyzabcdefghijklm0123
ssmtp_mailhub=your smtp gateway, eg. smtp.gmail.com:587
weather_api=your api key from openweather, eg. abcdef0123456789abcdef0132456789
EOF
```
Run installation script:
```bash
$ ./install.sh
```

## Graphs
### Graph of heating for last 24 hours
![Graph of heating for the last 24 hours](doc/heating24.png)

### Graph of heating for last week
![Graph of heating for the last week](doc/heating1w.png)

### Graph of heating for last month
![Graph of heating for last month](doc/heating1m.png)

### Graph of heating for the whole season
![Graph of heating throughout the season](doc/heating_season.png)

