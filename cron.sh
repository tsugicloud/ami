#! /bin/bash

echo "I am Cron Cron I Am"
date

echo ===== Updating main web site 
cd /var/www/html
git pull

echo ===== Updating /tsugi
cd /var/www/html/tsugi
git pull

echo ==== tsugicloud Database upgrade
sleep 2
cd /var/www/html/tsugi/admin
php upgrade.php

echo ==== Tool pull
sleep 2
cd /var/www/html/tsugi/admin/install
php update.php

