#!/bin/bash
sudo apt-get update

# robin-round database for heating and weather data
sudo apt-get install -y rrdtool
source rrd_create.sh

# for emailing
sudo apt-get install -y mailutils

# calculator
sudo apt-get install -y bc

# Install ssmtp for emailing
sudo apt-get install -y ssmtp

# Install jq parser - for JSON processing (for weather)
sudo apt-get install -y jq

# configure logs
sudo mkdir -m775 /var/log/poltergeist
sudo chown :adm /var/log/poltergeist

# Log rotation setting
sudo bash -c 'cat <<EOF >/etc/logrotate.d/poltergeist
/var/log/poltergeist/*.log
{
  su root adm
  rotate 600
  monthly
  missingok
  dateext dateformat -%Y%m%d-%s
  notifempty
  delaycompress
  compress
}
EOF'

# set Project HOME (from actual folder)
PROJECT_HOME=$(pwd)
sudo bash -c "echo \"export POLTERGEIST_HOME=$PROJECT_HOME\" > /etc/profile.d/poltergeist.sh"

# Actualize crontab.txt file with PROJECT_HOME
sed -i "s|^POLTERGEIST_HOME.*|POLTERGEIST_HOME=${PROJECT_HOME}|" crontab.txt

# Defaults
ssmtp_mailhub=smtp.gmail.com:587

# Read config file
. poltergeist.conf

# Configure ssmtp.conf file
SSMTP_CONFIG=/etc/ssmtp/ssmtp.conf
grep -q -e '^root' $SSMTP_CONFIG || echo root | sudo tee --append $SSMTP_CONFIG
sudo sed -i "s/^root.*/root=${ssmtp_AuthUser}/" $SSMTP_CONFIG
grep -q -e '^AuthUser' $SSMTP_CONFIG || echo AuthUser | sudo tee --append $SSMTP_CONFIG
sudo sed -i "s/^AuthUser.*/AuthUser=${ssmtp_AuthUser}/" $SSMTP_CONFIG
grep -q -e '^AuthPass' $SSMTP_CONFIG || echo AuthPass | sudo tee --append $SSMTP_CONFIG
sudo sed -i "s/^AuthPass.*/AuthPass=${ssmtp_AuthPass}/" $SSMTP_CONFIG
grep -q -e '^mailhub' $SSMTP_CONFIG || echo mailhub | sudo tee --append $SSMTP_CONFIG
sudo sed -i "s/^mailhub.*/mailhub=${ssmtp_mailhub}/" $SSMTP_CONFIG
grep -q -e '^UseSTARTTLS' $SSMTP_CONFIG || echo UseSTARTTLS | sudo tee --append $SSMTP_CONFIG
sudo sed -i "s/^UseSTARTTLS.*/UseSTARTTLS=YES/" $SSMTP_CONFIG
grep -q -e '^UseTLS' $SSMTP_CONFIG || echo UseTLS | sudo tee --append $SSMTP_CONFIG
sudo sed -i "s/^UseTLS.*/UseTLS=YES/" $SSMTP_CONFIG

# Configure crontab (add/replace crontab.txt) and leave current crontab config
crontab -l | sed '/POLTERGEIST BEGIN/,/POLTERGEIST END/d' | cat crontab.txt - | crontab

# create directory for graphs
mkdir graphs
