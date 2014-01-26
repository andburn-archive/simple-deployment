#!/usr/bin/bash

CLEAN_INSTALL=$1

source deploy_lib_helper.sh
source deploy_lib_monitor.sh
source deploy_lib_test.sh

function clean_install {
	console_message 'Cleaning System Environment'

	console_message 'Updating pacakge repositories'
	apt-get -qq update

	console_message "Removing Apache"
	apt-get -q -y purge apache2
	console_message "Removing MySQL"
	apt-get -q -y purge mysql-server mysql-client
	
	console_message "Tidying Up Packages"
	apt-get -q -y autoremove
	apt-get -q -y autoclean

	console_message "Installing Apache"
	apt-get -q -y install apache2

	console_message "Setting up for MySql Install"
	echo mysql-server mysql-server/root_password password password | debconf-set-selections
	echo mysql-server mysql-server/root_password_again password password | debconf-set-selections
	console_message "Installing MySQL"
	apt-get -q -y install mysql-server mysql-client
}

#--- Do a clean install if required
if [ $CLEAN_INSTALL -eq 1 ] ; then
	clean_install
fi

#--- Backup live application

console_message 'Stopping Services'
/etc/init.d/apache2 stop
/etc/init.d/mysql stop

# Delete old backups
rm -rf ~/deploy_live*
rm ~/live*tgz

# create new backup dirs
TSTAMP=$(date +%s)
mkdir -p ~/deploy_live_$TSTAMP/backup/www
mkdir -p ~/deploy_live_$TSTAMP/backup/cgi-bin
# copy live to backup dir
cp -r /var/www/* ~/deploy_live_$TSTAMP/backup/www
cp -r /usr/lib/cgi-bin/* ~/deploy_live_$TSTAMP/backup/cgi-bin
# create a backup package, could be archived somewhere
cd ~/deploy_live_$TSTAMP/
tar -zcvf ../live_backup_$TSTAMP.tgz backup

# extract new application
tar -zxvf ../webpackage_preDeploy.tgz -C ./
# clear current files
rm -r /var/www/*
rm -r /usr/lib/cgi-bin/*
# copy in new files
cp apache/www/* /var/www/
cp apache/cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*.pl

# restart apache & mysql
/etc/init.d/apache2 start
/etc/init.d/mysql start

#--- Check Operation

ERRORS=0
test_infrastructure
ERRORS=$((ERRORS+$?))
test_application_running
ERRORS=$((ERRORS+$?))

# rollback to backup on errors
if [ $ERRORS -gt 0 ] ; then
	console_error "AWS Deployment failed, rolling back"
	console_message 'Stopping Services'
	/etc/init.d/apache2 stop
	/etc/init.d/mysql stop
	# clear current files
	rm -r /var/www/*
	rm -r /usr/lib/cgi-bin/*
	# copy in backup files
	cp www/* /var/www/
	cp cgi-bin/* /usr/lib/cgi-bin/
	chmod a+x /usr/lib/cgi-bin/*.pl
	# restart apache & mysql
	/etc/init.d/apache2 start
	/etc/init.d/mysql start
	console_message "Rollback complete"
fi

console_message "AWS Deployment successfull"
