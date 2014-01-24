#!/usr/bin/bash

# import config file
source vbox_scripts/deploy.cfg

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
cp $REPO_NAME/vbox_scripts/* ./
cp -r $REPO_NAME/sample_app_v$APP_VERSION ./webpackage
rm -rf $REPO_NAME

# now call scripts in sandbox on remote machine
bash deploy.sh
