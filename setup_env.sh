#!/usr/bin/bash

# GitHub repo
REPO_NAME="simple_deployment"
REPO_URL="https://github.com/andburn/$REPO_NAME.git"

# monitor script location
MONITOR_DIR="/dep_monitor"

# the version of the app to build
APP_VERSION=1
if [ -n "$1" ] ; then
	# not doing any checks here
	# assuming its going to be 
	# either 1 or 2
	APP_VERSION=$1
fi

# create random sandbox dir
SANDBOX="sandbox_$RANDOM"
echo "----- Creating sandbox $SANDBOX"
cd /tmp
mkdir $SANDBOX
cd $SANDBOX
# create directory structure
mkdir build
mkdir integrate
mkdir test
mkdir deploy
mkdir webpackage

# updating apt repositories
echo "----- Updating apt repositories"
apt-get -qq update

# check if git is installed
git --version >/dev/null
if [ $? -ne 0 ] ; then
	echo "----- Installing git"
	apt-get install git
fi

# clone github repo
echo "----- Cloning source from GitHub"
git clone $REPO_URL
cp $REPO_NAME/deploy_scripts/* ./
cp -r $REPO_NAME/sample_app_v$APP_VERSION/* ./webpackage

# copy monitor scripts to location
echo "----- Setup/Update monitoring scripts"
mkdir -p $MONITOR_DIR
rm -rf $MONITOR_DIR/*
#cp $REPO_NAME/* $MONITOR_DIR/

# delete repo directory
rm -rf $REPO_NAME

# run script in sandbox on remote machine
bash deploy.sh
