#!/bin/bash

source deploy_lib_helper.sh

# uninstall necessary programs and then reinstall
function clean_install {
	console_message 'Cleaning System Environment'

	console_message 'Stopping Services'
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
}

# application integration
function app_integrate {
	cd webpackage/html
	# use tidy utility to check html
	tidy *.htm* > /dev/null 2>&1
	local TIDYSTATUS=$?
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
}

function extract_package {
	local package=$1
	local directory=$2
	if [ -z $package ] ; then
		console_error "extract_package: invalid arguments"
	elif [ -z $directory ] ; then
		console_error "extract_package: invalid arguments"
	fi
	echo "Extracting $package into $dir"
	# move pack to dir
	mv $package $directory
	cd $directory
	# extract pack
	tar -zxf $package
}

function create_package {
	local package=$1
	local directory=$2
	if [ -z $package ] ; then
		console_error "create_package: invalid arguments"
	elif [ -z $directory ] ; then
		console_error "create_package: invalid arguments"
	fi
	echo "Creating $package from $dir"
	# create a tar archive from $directory
	tar -zcf $package $directory
	cd ..
}

# problem with this if it more files added
# but existing don't change sum will be ok
function createChecksumFile {
	top_dir=$1
	out_file=$2
	# empty out_file, if exists
	cat /dev/null > $out_file
	files=$(find $top_dir -type f)
	# $(find public_html -type f -name *.php)
	for f in $files
	do
		MD5SUM=$(md5sum -b $f)
		echo $MD5SUM >> $out_file
	done
	# return somethign
}

# quickest way to checksum checksums! and compare
# in case of any new files in one package, could be missed
# could be issue with binary'*' and text' '
function compareChecksumFiles {
	SUM1=$(md5sum $1 | cut -f 1 -d' ')
	SUM2=$(md5sum $2 | cut -f 1 -d' ')
	if [ "$SUM1" = "$SUM2" ] ; then
		return 0
	else
		return 1
	fi
}
