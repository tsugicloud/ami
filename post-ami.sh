echo Running post-ami `date "+%F-%T"`
touch /tmp/post-ami-`date "+%F-%T"`

echo "====== Environment variables"
env | sort

apt-get update

echo ======= Installing Postfix
echo "postfix postfix/mailname string ${TSUGI_MAIL_DOMAIN}" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt-get install -y mailutils

echo "Finish the rest manually"
exit

# This might be a read-write volume from before
if [ ! -d /var/www/html/tsugi/.git ]; then
  cd /var/www/html/
  git clone https://github.com/tsugiproject/tsugi.git

  # Make sure FETCH_HEAD and ORIG_HEAD are created
  cd /var/www/html/tsugi
  git pull
fi

mv /root/www/* /var/www/html
mv /var/www/html/config.php /var/www/html/tsugi

# Create the tables
cd /var/www/html/tsugi/admin
php upgrade.php


cp /usr/bin/git /usr/local/bin/gitx
chown www-data:www-data /usr/local/bin/gitx
chown -R www-data:www-data /var/www/html/tsugi

# Make git work from the browser
if [ -n "$SETUP_GIT" ] ; then
  echo "Enabling git from the browser"
  chmod a+s /usr/local/bin/gitx
fi

echo ======= Cleanup Start
df
apt-get -y autoclean
apt-get -y clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*
echo ======= Cleanup Done
df
echo ======= Cleanup Done

