#!/bin/bash

source deploy_lib_monitor.sh

MONITOR_LOG="/dep_monitor/monitor.log"
AWS_IP="54.194.174.13"

function monitor_log {
	# TODO: format tstamp
	local tstamp=$(date)
	echo "[$tstamp] $1" >> $MONITOR_LOG
}

function isAWSApacheUp {
	nc -z -w 3 $AWS_IP 80
	return $?
}

function isAWSMySqlUp {
	nc -z -w 3 $AWS_IP 3306
	return $?
}

function isAppRunning {
	curl "http://$AWS_IP:80" | grep "<title>Sample App</title>"
	return $?
}

isAWSApacheUp
if [ "$?" -ne 0 ]; then
	monitor_log "AWS Apache is down."
fi

isAWSMySqlUp
if [ "$?" -ne 0 ]; then
	monitor_log "AWS Mysql is down."
fi

isAppRunning
if [ "$?" -ne 0 ]; then
	monitor_log "Application is not running as expected."
fi