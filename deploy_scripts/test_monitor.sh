#!/usr/bin/bash

source deploy_lib_helper.sh
source deploy_lib_monitor.sh

# Test Level 1 functions, on build server

function test_isApacheRunning {
	/etc/init.d/apache2 stop > /dev/null 2>&1
	sleep 1
	isRunning apache2
	local neg=$?
	/etc/init.d/apache2 start > /dev/null 2>&1
	sleep 1
	isRunning apache2
	local pos=$?
	if [ $neg -eq 0 ] && [ $pos -eq 1 ] ; then
		console_message "OK   - test_isApacheRunning"
	else
		console_message "FAIL - test_isApacheRunning"
	fi
}

function test_isApacheListening {	
	/etc/init.d/apache2 stop > /dev/null 2>&1
	sleep 1
	isTCPlisten 80 > /dev/null 2>&1
	local neg=$?
	/etc/init.d/apache2 start > /dev/null 2>&1
	sleep 1
	isTCPlisten 80 > /dev/null 2>&1
	local pos=$?
	if [ $neg -eq 0 ] && [ $pos -eq 1 ] ; then
		console_message "OK   - test_isApacheListening"
	else
		console_message "FAIL - test_isApacheListening"
	fi
}

function test_isMysqlListening {	
	/etc/init.d/mysql stop > /dev/null 2>&1
	sleep 1
	isTCPlisten 3306 > /dev/null 2>&1
	local neg=$?
	/etc/init.d/mysql start > /dev/null 2>&1
	sleep 1
	isTCPlisten 3306 > /dev/null 2>&1
	local pos=$?
	if [ $neg -eq 0 ] && [ $pos -eq 1 ] ; then
		console_message "OK   - test_isMysqlListening"
	else
		console_message "FAIL - test_isMysqlListening"
	fi
}

function test_isApacheRemoteUp {	
	/etc/init.d/apache2 stop > /dev/null 2>&1
	sleep 1
	isTCPremoteOpen 127.0.0.1 80 > /dev/null 2>&1
	local neg=$?
	/etc/init.d/apache2 start > /dev/null 2>&1
	sleep 1
	isTCPremoteOpen 127.0.0.1 80 > /dev/null 2>&1
	local pos=$?
	if [ $neg -eq 0 ] && [ $pos -eq 1 ] ; then
		console_message "OK   - test_isApacheRemoteUp"
	else
		console_message "FAIL - test_isApacheRemoteUp"
	fi
}

function test_isMysqlRunning {
	/etc/init.d/mysql stop > /dev/null 2>&1
	sleep 1
	isRunning mysqld
	local neg=$?
	/etc/init.d/mysql start > /dev/null 2>&1
	sleep 1
	isRunning mysqld
	local pos=$?
	if [ $neg -eq 0 ] && [ $pos -eq 1 ] ; then
		console_message "OK   - test_isMysqlRunning"
	else
		console_message "FAIL - test_isMysqlRunning"
	fi
}

function test_isMysqlRemoteUp {
	/etc/init.d/mysql stop > /dev/null 2>&1
	sleep 1
	isTCPremoteOpen 127.0.0.1 3306 > /dev/null 2>&1
	local neg=$?
	/etc/init.d/mysql start > /dev/null 2>&1
	sleep 1
	isTCPremoteOpen 127.0.0.1 3306 > /dev/null 2>&1
	local pos=$?
	if [ $neg -eq 0 ] && [ $pos -eq 1 ] ; then
		console_message "OK   - test_isMysqlRemoteUp"
	else
		console_message "FAIL - test_isMysqlRemoteUp"
	fi
}

test_isApacheRunning
test_isApacheListening
test_isMysqlListening
test_isApacheRemoteUp
test_isMysqlRunning
test_isMysqlRemoteUp
