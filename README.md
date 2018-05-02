# Poltergeist
Home Heating Control Center

# Installation

$ cd _project directory_

create configuration file _'poltergeist.conf'_:
```bash
$ cat <<EOF >polstergeist.conf
#!/bin/bash
ssmtp_AuthUser=_your email address, eg. you@yourdomain.com_
ssmtp_AuthPass=_your smtp password, e.g. xyzabcdefghijklm0123_
ssmtp_mailhub=_your smtp gateway, eg. smtp.gmail.com:587_
weather_api=_your api key from openweather, eg. abcdef0123456789abcdef0132456789_
EOF
```
Run installation script:
```bash
$ ./install.sh
```
