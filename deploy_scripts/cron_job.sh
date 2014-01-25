#!/bin/bash

source deploy_lib_monitor.sh

MONITOR_LOG="/dep_monitor/monitor.log"
AWS_IP="54.194.174.13"

function monitor_log {
	# TODO: format better
	local tstamp=$(date)
	echo "[$tstamp] $1" >> $MONITOR_LOG
}

function isAWSApacheUp {
	isTCPremoteOpen $AWS_IP 80
	return $?
}

function isAWSMySqlUp {
	isTCPremoteOpen $AWS_IP 3306
	return $?
}

isAWSApacheUp
if [ "$?" -eq 0 ]; then
	monitor_log "AWS Apache is down"
fi

isAWSMySqlUp
if [ "$?" -eq 0 ]; then
	monitor_log "AWS Mysql is down"
fi