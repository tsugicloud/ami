echo Running post-ami `date "+%F-%T"`
touch /tmp/post-ami-`date "+%F-%T"`

# source /home/ubuntu/tsugi_env.sh

echo "====== Environment variables"
env | sort

cat << EOF >> /home/ubuntu/.bashrc
PS1="\e[0;32m${TSUGI_SERVICENAME}:\e[m\e[0;34m\w\e[m$ "
EOF

apt-get update

echo ======= Installing Postfix
echo "postfix postfix/mailname string ${TSUGI_MAIL_DOMAIN}" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt-get install -y mailutils

if [ ! -d /efs ]; then
    echo ====== Setting up the efs volume
    mkdir /efs
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $TSUGI_NFS_VOLUME:/ /efs
    if grep --quiet /efs /etc/fstab ; then
        echo Fstab already has efs mount
    else
        echo Adding efs mount to /etc/fstab
        cat << EOF >> /etc/fstab
$TSUGI_NFS_VOLUME:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,noresvport 0 0
EOF
    fi
fi

if [ ! -d /efs ]; then
    echo Failed to mount /efs - execution terminated
    exit 1
fi

if [ ! -d /efs/blobs ]; then
  mkdir /efs/blobs
fi
if [ ! -d /efs/html ]; then
  mkdir /efs/html
fi

echo "Patching efs permissions"
chown -R www-data:www-data /efs

# If we are making a fresh install
if [ ! -d /efs/html/tsugi/.git ]; then
  cd /efs/html/
  if [ -n "$MAIN_REPO" ] ; then
    echo Cloning $MAIN_REPO
    git clone $MAIN_REPO site
  else
    echo Cloning default repo
    git clone https://github.com/tsugicloud/dev-jekyll-site.git site
  fi
  cd site
  mv .git* * ..
  cd ..
  rm -r site

  cd /efs/html/
  git clone https://github.com/tsugiproject/tsugi.git

  # Make sure FETCH_HEAD and ORIG_HEAD are created
  cd /efs/html
  git pull
  cd /efs/html/tsugi
  git pull
fi

# Sanity Check
if [[ -f /efs/html/tsugi/admin/upgrade.php ]] ; then
  echo Tsugi checkout looks good
else
  echo Tsugi checkout fail
  exit 1
fi

# Fix the config.php file
if [ ! -f /efs/html/tsugi/config.php ] ; then
    echo Building config.php
    php /home/ubuntu/ami/fixconfig.php < /home/ubuntu/ami/config.php > /efs/html/tsugi/config.php
fi

echo Copying to /var/www/html
rsync -avh /efs/html/ /var/www/html/ --delete

# Create/update the Tsug database tables
cd /var/www/html/tsugi/admin
php upgrade.php

# Make git work from the browser
cp /usr/bin/git /usr/local/bin/gitx
chown www-data:www-data /usr/local/bin/gitx
chmod a+s /usr/local/bin/gitx

# Patch permissions
chown -R www-data:www-data /var/www/html/tsugi

# Create the tables
cd /var/www/html/tsugi/admin
php upgrade.php

# Make git work from the browser
if [ -n "$TSUGI_SETUP_GIT" ] ; then
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

echo Setting Apache to auto-start on reboot
update-rc.d apache2 defaults

echo Starting Apache
/usr/sbin/apachectl start

