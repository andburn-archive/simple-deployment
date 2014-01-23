#!/usr/bin/bash

# import some external functions
source deploy_lib_helper.sh
source deploy_lib_build.sh
source deploy_lib_monitor.sh

## RUNS ON BUILD SERVER ##

REPO_NAME="simple_deployment"
REPO_URL="https://github.com/andburn/$REPO_NAME.git"

# updating apt repositories
console_message "Updating apt repositories"
apt-get -qq update
echo 'apt-get update (done)'

# check if git is installed
git --version >/dev/null
if [ $? -ne 0 ] ; then
	console_message "Installing git"
	apt-get install git
fi

# get deployment scripts
console_message "Cloning source from GitHub"
cd ~
git clone $REPO_URL
cd "$REPO_NAME/vbox_scripts"
ls -la
