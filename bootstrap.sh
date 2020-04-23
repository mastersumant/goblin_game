#!/usr/bin/env bash

sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password rootpass'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password rootpass'
apt-get update
apt-get install -y apache2
apt-get install -y php5
apt-get install -y mysql-server-5.5 libapache2-mod-auth-mysql php5-mysql
apt-get install php5 libapache2-mod-php5 php5-mcrypt

# Ensure we can access the database
# http://www.thisprogrammingthing.com/2013/getting-started-with-vagrant/
if [ ! -f /var/log/databasesetup ];
then
    echo "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'wordpresspass'" | mysql -uroot -prootpass
    echo "CREATE DATABASE wordpress" | mysql -uroot -prootpass
    echo "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost'" | mysql -uroot -prootpass
    echo "flush privileges" | mysql -uroot -prootpass

    touch /var/log/databasesetup

    if [ -f /vagrant/data/initial.sql ];
    then
        mysql -uroot -prootpass wordpress < /vagrant/data/initial.sql
    fi
fi

# Configure Apache to serve our website publicly
if [ ! -h /var/www ]; 
then 

    rm -rf /var/www
    ln -fs /vagrant /var/www

    a2enmod rewrite

    sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default

    service apache2 restart
fi

#setup development environment
apt-get install -y vim
apt-get install -y git
apt-get install -y unzip

