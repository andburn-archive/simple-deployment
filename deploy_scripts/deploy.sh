#!/usr/bin/bash

# import config file
source deploy.cfg
# import some external functions
source deploy_lib_helper.sh
source deploy_lib_build.sh
source deploy_lib_monitor.sh
source deploy_lib_test.sh

SANDBOX_DIR=$(pwd)

console_message "Checking Source Package"
# create a checksum of all files in webpackage
createChecksumFile webpackage webpackage.md5
# create a tar archive of the webpackage
tar -zcvf webpackage_preBuild.tgz webpackage

# TODO: what if /tmp/last_build.md5 doesn't exist (better location)
# compare previous build with current one
compareChecksumFiles /tmp/last_build.md5 webpackage.md5
FILECHANGE=$?
# TODO: only change on successfull deployment (i.e. reflects live package)
#cp webpackage.md5 /tmp/last_build.md5

# if there is no difference in the files do nothing and exit
if [ $FILECHANGE -eq 0 ]
then
	console_error "No change in files, doing nothing and exiting."
	exit 1
fi

# delete webpackage dir
rm -rf webpackage

#--- Clean Build/Test Server ---#

# TODO: remove this
DOCLEAN=1

if [ $DOCLEAN -eq 0 ] ; then

console_message 'Cleaning System Environment'

# TODO: message relating to service
# Stop Apache & MySQL services
/etc/init.d/apache2 stop
/etc/init.d/mysql stop

console_message 'Updating pacakge repositories'
apt-get -qq update

console_message "Removing Apache"
apt-get -q -y purge apache2
console_message "Removing MySQL"
apt-get -q -y purge mysql-server mysql-client
console_message "Removing Tidy"
apt-get -q -y purge tidy

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
console_message "Installing Tidy"
apt-get -q -y install tidy

fi

#--- Start Build Process ---#

console_message "Building application"

# move preBuild archive to build folder
mv webpackage_preBuild.tgz build
cd build
# extract preBuild
tar -zxvf webpackage_preBuild.tgz
# run build perl script
perl $SANDBOX_DIR/buildapp.pl webpackage
# create preIntegrate archive
tar -zcvf ../webpackage_preIntegrate.tgz webpackage
# back up to sandbox level
cd ..
# TODO: sort out this ERRORCHECK
ERRORCHECK=0

#--- Start Integration Process ---#

console_message "Integrating application"

mv webpackage_preIntegrate.tgz integrate
cd integrate
tar -zxvf webpackage_preIntegrate.tgz
cd webpackage/html
# use tidy utility to check html
tidy *.htm* > /dev/null 2>&1
TIDYSTATUS=$?
if [ $TIDYSTATUS -eq 2 ] ; then
	echo tidy: errors found in html files
	console_error "Errors found in HTML files, exiting"
	exit 1;
elif [ $TIDYSTATUS -eq 1 ] ; then
	console_warning "The HTML files generated warnings, ignoring"
fi
cd ../..
mkdir -p apache/cgi-bin
mkdir -p apache/www
cp webpackage/html/* apache/www/
cp webpackage/cgi/* apache/cgi-bin
cp webpackage/templates/* apache/cgi-bin
tar -zcvf ../webpackage_preTest.tgz apache

# back up to sandbox level
cd ..
ERRORCHECK=0

#--- Start Test Process ---#

console_message "Testing application"

mv webpackage_preTest.tgz test
cd test
tar -zxvf webpackage_preTest.tgz

# Start services
/etc/init.d/apache2 start
/etc/init.d/mysql start

# create database
cat <<FINISH | mysql -uroot -ppassword
drop database if exists dbtest;
CREATE DATABASE dbtest;
GRANT ALL PRIVILEGES ON dbtest.* TO dbtestuser@localhost IDENTIFIED BY 'dbpassword';
use dbtest;
drop table if exists custdetails;
create table if not exists custdetails (
name         VARCHAR(30)   NOT NULL DEFAULT '',
address         VARCHAR(30)   NOT NULL DEFAULT ''
);
insert into custdetails (name,address) values ('John Smith','Street Address'); select * from custdetails;
FINISH

cd apache/cgi-bin
perl -w accept_form.pl name="Bill Jones" address="No fixed abode" | grep "<td>Bill Jones</td><td>No fixed abode</td>"
CGI_STATUS=$?
cd ../..
if [ $CGI_STATUS -ne 0 ] ; then
	console_error "CGI script failed test, aborting"
	exit 1
fi
console_message "CGI script passed test"
tar -zcvf ../webpackage_preDeploy.tgz apache

console_message "Setting up test server"

cp apache/www/* /var/www/
cp apache/cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*.pl

# Start services
/etc/init.d/apache2 start
/etc/init.d/mysql start

console_message "Testing on test server"
console_warning "Check manually on 127.0.0.1:8080"

test_application_running
if [ $? -ne 0 ] ; then
	console_error "Server test failed, aborting"
	exit 1
fi
console_message "Server test passed"

# back up to sandbox level
cd ..
ERRORCHECK=0

## --- Deploying to Live AWS Server --- ## ## ----------------------------------------------------------##

console_message "Deploy to live AWS Server"

AWS_IP="54.194.174.13"
AWS_URL="ec2-54-194-174-13.eu-west-1.compute.amazonaws.com"
AWS_PEM="/home/testuser/.ssh/aws.pem"

scp -i $AWS_PEM webpackage_preDeploy.tgz ubuntu@$AWS_URL:~
ssh -i $AWS_PEM ubuntu@$AWS_URL "sudo bash -s" < deploy_aws.sh

