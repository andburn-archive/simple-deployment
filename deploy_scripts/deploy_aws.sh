#!/usr/bin/bash

#--- Backup live application

/etc/init.d/apache2 stop
/etc/init.d/mysql stop

TSTAMP=$(date +%s)
mkdir -p ~/deploy_live_$TSTAMP/backup/www
mkdir -p ~/deploy_live_$TSTAMP/backup/cgi-bin

cp -r /var/www/* ~/deploy_live_$TSTAMP/backup/www
cp -r /usr/lib/cgi-bin/* ~/deploy_live_$TSTAMP/backup/cgi-bin

cd ~/deploy_live_$TSTAMP/
tar -zcvf ../live_backup_$TSTAMP.tgz backup

tar -zxvf ../webpackage_preDeploy.tgz -C ./

rm -r /var/www/*
rm -r /usr/lib/cgi-bin/*

cp apache/www/* /var/www/
cp apache/cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*.pl

/etc/init.d/apache2 start
/etc/init.d/mysql start
