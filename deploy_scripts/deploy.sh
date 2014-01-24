#!/usr/bin/bash

# import some external functions
source deploy_lib_helper.sh
source deploy_lib_build.sh
source deploy_lib_monitor.sh
source deploy_lib_test.sh

# AWS instance data
AWS_IP="54.194.174.13"
AWS_URL="ec2-54-194-174-13.eu-west-1.compute.amazonaws.com"
# script needs pem file on VBox machine at:
AWS_PEM="/home/testuser/.ssh/aws.pem"

# keep track of root build dir
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

clean_install

#--- Start Build Process ---#

console_message "Building application"

# move preBuild archive to build folder
extract_package "webpackage_preBuild.tgz" "build"
# run build perl script
perl $SANDBOX_DIR/buildapp.pl webpackage
if [ $? -ne 0 ] ; then
	console_error "Build failed"
	exit 1
fi
echo "HTML templates merged"
# create preIntegrate archive
create_package "../webpackage_preIntegrate.tgz" "webpackage"


#--- Start Integration Process ---#

console_message "Integrating application"

extract_package "webpackage_preIntegrate.tgz" "integrate"
# perform integration step
app_integrate
create_package "../webpackage_preTest.tgz" "apache"


#--- Start Test Process ---#

console_message "Testing application"

extract_package "webpackage_preTest.tgz" "test"

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

# run cgi form script, outside apache
test_cgi_script
console_message "CGI script passed test"

console_message "Setting up test server"
# copy all content to apache on test server
cp apache/www/* /var/www/
cp apache/cgi-bin/* /usr/lib/cgi-bin/
chmod a+x /usr/lib/cgi-bin/*.pl

# restart apache
/etc/init.d/apache2 restart
/etc/init.d/mysql restart

# test server state
console_message "Testing test server infrastructure"
test_infrastructure

console_message "Testing on test server"
console_warning "Check manually on 127.0.0.1:8080"

test_application_running
if [ $? -ne 0 ] ; then
	console_error "Server test failed, aborting"
	exit 1
fi
console_message "Server test passed"

# make final package to deploy to the server
create_package "../webpackage_preDeploy.tgz" "apache"


## --- Deploying to Live AWS Server --- ##

console_message "Deploy to live AWS Server"

# check server is up
isIPAlive $AWS_IP
if [ $? -eq 0 ] ; then
	console_error "AWS machine ($AWS_IP) is not responding."
	exit 1
fi

scp -i $AWS_PEM webpackage_preDeploy.tgz ubuntu@$AWS_URL:~
ssh -i $AWS_PEM ubuntu@$AWS_URL "sudo bash -s" < deploy_aws.sh

