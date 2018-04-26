# Setup a scalable app server instance behind ELB
# Leave hostname alone

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
locale -a
env

echo ======= Update 1
apt-get update 

apt-get install -y build-essential
apt-get install -y python-software-properties
apt-get install -y software-properties-common
apt-get install -y byobu curl git htop man unzip vim wget
apt-get install -y ca-certificates
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

echo ======= Update 2
apt-get update
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2
add-apt-repository -y ppa:ondrej/mysql-5.6
add-apt-repository -y ppa:certbot/certbot

echo ======= Update 3
apt-get update

apt-get install -y apache2

# apt-cache search php7

apt-get install -y php7.1
apt-get install -y libapache2-mod-php7.1 php7.1-mysql php7.1-curl php7.1-json
apt-get install -y php7.1-mbstring php7.1-zip php7.1-xml php7.1-gd
apt-get install -y php7.1-apc
apt-get install -y php7.1-intl

apt-get install -y mysql-client
apt-get install -y nfs-common  # For EFS

a2enmod -q rewrite dir expires headers
phpenmod mysqlnd pdo_mysql intl

echo ======= Cleanup Start
df
apt-get --purge -y remove software-properties-common
apt-get -y autoclean
apt-get -y clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*
echo ======= Cleanup Done
df
echo ======= Cleanup Done

cp apache2.conf /etc/apache2

echo ===========================
echo === PRE-AMI is Complete ===
echo ===========================

echo Next is to shutdown and make the AMI
echo
echo systemctl poweroff
echo
