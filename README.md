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
