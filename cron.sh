#! /bin/bash

echo "I am Cron Cron I Am"
date

cd /var/www/html
git pull

# Install any needed tools if we are second to the cluster
sudo su -s "/home/ubuntu/ami-sql/tool_update.sh" www-data

# Wait some random time so we don't all hit at once
sleep $[ ( $RANDOM % 60 ) + 1 ]s

# Create/update the Tsugi database tables
sudo su -s "/home/ubuntu/ami-sql/db_upgrade.sh" www-data

