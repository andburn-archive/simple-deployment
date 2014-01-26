#!/bin/bash

function console_message {
  tput setaf 2
  echo "|-------- $1 -------|"
  tput sgr0
}

function console_error {
  tput setaf 1
  echo ">-------- $1 -------<"
  tput sgr0
  local d=$(date)
  echo "[$d] $1" >> /dep_monitor/build.log
}

function console_warning {
  tput setaf 5
  echo "$1"
  tput sgr0
  echo "[$d] $1" >> /dep_monitor/build.log
}

function update_cron_job {
	echo "*/2 * * * * /dep_monitor/cron_job.sh" | sudo crontab -
}