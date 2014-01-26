#!/bin/bash

source deploy_lib_monitor.sh

MONITOR_LOG="/dep_monitor/monitor.log"
AWS_IP="54.194.174.13"
AWS_PEM="/home/testuser/.ssh/aws.pem"
ADMINISTRATOR="admin@example.com"
MAILSERVER="smtp.yourisp.com"

ps_apache="ps -ef | grep apache | grep -v grep"
ps_mysql="ps -ef | grep mysql | grep -v grep"

function monitor_log {
	# TODO: format tstamp
	local tstamp=$(date)
	echo "[$tstamp] $1" >> $MONITOR_LOG
}

function isAppRunning {
	curl "http://$AWS_IP" | grep "<title>Sample App</title>"
	return $?
}

ERRORS=0
# check remote apache process
ssh -i $AWS_PEM ubuntu@$AWS_IP "sudo $ps_apache"
if [ "$?" -ne 0 ]; then
	monitor_log "AWS Apache is down."
	$ERRORS=1
fi

# check remote mysql process
ssh -i $AWS_PEM ubuntu@$AWS_IP "sudo $ps_mysql"
if [ "$?" -ne 0 ]; then
	monitor_log "AWS Mysql is down."
	$ERRORS=1
fi

isAppRunning
if [ "$?" -ne 0 ]; then
	monitor_log "Application is not running as expected."
	$ERRORS=1
fi

if [ $ERRORS -ne 0 ] ; then
	#perl sendmail.pl $ADMINISTRATOR $MAILSERVER
fi